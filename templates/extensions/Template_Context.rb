require 'mustache'

class Mustache::Context

  def compile name, code
    # if name == :address
    #   require 'rubygems'; require 'ruby-debug'; debugger
    # end
    
    # Compile the Ruby for this section now that we know what's
    # inside the section.
    ctx ||= self
    if v = ctx[name]
      if v == true
        instance_eval code
      elsif v.is_a?(Proc)
        v.call( code )
      else
        v = [v] unless v.is_a?(Array) # shortcut when passed non-array
        v.map { |h| 
          ctx.push(h); 
          r = instance_eval(code); 
          ctx.pop; 
          r 
        }.join
      end
    end
    
  end
  
end # === class 

