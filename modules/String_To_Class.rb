
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
