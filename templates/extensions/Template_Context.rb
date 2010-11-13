require 'mustache'

class Mustache::Context

  def compile name, &blok
    
    # Compile the Ruby for this section now that we know what's
    # inside the section.
    ctx ||= self
    if v = ctx[name]
      if v == true
        yield
      elsif v.is_a?(Proc)
        v.call( blok.call )
      else
        v = [v] unless v.is_a?(Array) # shortcut when passed non-array
        v.map { |h| 
          ctx.push(h); 
          r = ctx.instance_eval( &blok ); 
          ctx.pop; 
          r 
        }.join
      end
    end
    
  end
  
end # === class 

