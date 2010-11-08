require 'tenjin'

class String
  def m!
    self[/[^a-z0-9\_]/] ? 
      self : 
      "{{#{self}}}"
  end
end # === class

module MAB::Template

  # This class is used to evaluate the
  # final template code after it has
  # been turned from Markaby into a
  # compiled templated.
  class Context < Tenjin::Context

    def within?
      !!@within
    end

    def method_missing name, *args
      if within?
      "#{@within.fetch(name.to_s) { super } }"
      else
        super
      end
    end

    def loop(hsh, &blok)
      @within = hsh
      _buf <<  "!! within hash"
      yield
      @within = false 
      nil
    end
    
  end # === class Context
  
  # This module is included into
  # Markaby to generate the template
  # delimiters.
  module Embed
    
    attr_accessor :context_name 

    def method_missing name, *args
      super unless context_name && args.empty?
      
      text %~
        ${
          #{context_name}.fetch('#{name}') { 
            raise "Unknown key: '#{name}' for #{context_name}" 
          } 
        }
      ~
      
    end

    def show_if name, &blok
      text %~
        <?rb if @#{name} ?>
        <?rb end ?>
      ~
    end

    def loop name, &blok
      self.context_name = name
      text %~
        <?rb loop @#{name} do ?>
      ~
      
      yield
      
      text %~
        <?rb end ?>
      ~
    end
  end # === module Embed

end # === module MAB::Template
