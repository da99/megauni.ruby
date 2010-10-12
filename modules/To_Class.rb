
module Symbol_To_Class

	def to_singular
    to_s.sub(/s$/, '')
	end
	  
	def to_class_name
		to_s.split('_').map(&:capitalize).join('_')
	end
	
	def to_model_class_name
		to_s.to_singular.to_class_name
	end
	
	def to_class
		Object.const_get self
	end

end # === module Symobol_To_Class

module String_To_Class

	def to_singular
    sub(/s$/, '')
	end
	  
	def to_class_name
		split('_').map(&:capitalize).join('_')
	end
	
	def to_model_class_name
		to_singular.to_class_name
	end
	
	def to_class
		Object.const_get self.to_sym
	end

end # === module String_To_Class


module To_Class
  
  class << self
    
    def extended klass
      case self
        when Symbol
          klass.extend Symbol_To_Class
        when String
          klass.extend String_To_Class
        else
          raise "I don't know what to do with this: #{self.inspect}"
      end
    end

  end # === class

end # === modile
