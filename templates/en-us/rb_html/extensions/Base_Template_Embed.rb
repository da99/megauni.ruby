require 'mustache'

class String
  def m!
    self[/[^a-z0-9\_]/] ? 
      self : 
      "{{ #{self} }}"
  end
end # === class

class Mustache::Generator

  def on_section(name, content)
    code = compile(content)
    
    ev(<<-compiled)
ctx.compile( #{name.to_sym.inspect} ) { #{code} }
compiled
  end
  
end # === class

# This module is included into
# Markaby to generate the template
# delimiters.
module Ruby_To_Html::Base_Template_Embed


  def mustache name
    if block_given?
      raise ArgumentError, "Block no longer allowed here."
    end

    text %~
        {{ #{name} }}
      ~
  end

  def if_not mus, &blok
    mustache_statement mus, '^', &blok
  end
  alias_method :if_no,    :if_not
  alias_method :if_empty, :if_not

  def show_if mus, &blok
    unless mus['?']
      raise ArgumentError, ':show_if only works with __? messages'
    end
    mustache_statement mus, &blok
  end

  def mustache_statement mus, delim = '#', &blok
    text %~
        {{#{delim} #{mus} }}
      ~

    yield

    text %~
        {{/ #{mus} }}

      ~ 
  end
  alias_method :loop, :mustache_statement
  alias_method :as, :mustache_statement


end # === module Ruby_To_Html::Template_Embed
