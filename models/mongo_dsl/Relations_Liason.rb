
class Mongo_Dsl::Relations_Liason
	
	class << self
		
		def relations 
			@relations ||= {}
		end

		def new_relation parent, type, name, child, foreign_key
			relations[parent] ||= {}
			relations[parent][name] = new( parent, type, name, child, foreign_key )
		end
		
		def get_relation parent, name
			relations[parent][name]
		end
		
	end # === self

	attr_reader :parent, :type, :name, :child, :foreign_key, :instance
	
	def initialize parent, type, name, child, foreign_key
		@parent = parent
		@type   = type
		@name   = name
		@child  = child
		@foreign_key = foreign_key.to_s
    @instance = nil
	end

	def method_missing name, *args
		relation = self.class.get_relation( child, name )
		return relation if relation
		super
	end

	def find doc_or_instance, selector_override, params_override
		# compose default selector
		# compose default params
		# Find and return results.
		  
		selector = {}
		params   = {}

		case type
		when :has_many
			case doc_or_instance
			when Hash
				selector[foreign_key] = doc_or_instance[foreign_key] || doc_or_instance[foreign_key.to_sym]
			when Array
				ids = doc_or_instance.map { |doc| 
					if doc.respond_to?(:data)
						doc.data._id
					elsif doc.is_a?(Hash)
						doc[foreign_key]
					else
						doc
					end
				}
				selector[foreign_key] = { :$in => ids }
			else
        @instance = doc_or_instance
				selector[foreign_key] = instance.data._id
			end
			
		when :belongs_to
			raise "not done"
		when :has_one	
			raise "not done"
		end
		
		# Update query with requested overrides.
		final_selector, final_params = \
			selector.update(selector_override), 
			params.update(params_override) 
		
		# Send back results.
    # 
		child.find.by( final_selector ).and( final_params ).cache_in(instance)

	end # === find

end # === class
