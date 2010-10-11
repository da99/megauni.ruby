
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

	attr_reader :parent, :type, :name, :child_name, :foreign_key, 
              :instance, :sub_relations,
              :selector, :params
	
	def initialize parent, type, name, child_name, foreign_key, &blok
    name_singular = name.to_s.sub( /s$/ , '')
		@parent = parent
		@type   = type
		@name   = name.to_sym
    @child_name = child_name ? 
      child_name : 
      (child_name.to_s.sub( /s$/, '' ).split('_').map(&:capitalize).join('_'))
    
		@foreign_key = foreign_key || (name_singular + '_id')
    
    @instance = nil
    @sub_relations = {}
    
    @selector = {}
    @params = {}
    
    instance_eval(&blok) if block_given? && parent.to_s =~ /Cafe_/
	end
  
  def child
    @Class_as_Object ||= Object.const_get(child_name.to_s.to_sym)
  end

	def method_missing name, *args
    return super if !args.empty?
    
		relation = self.class.get_relation( child, name )
		return relation if relation
    
    sub_relation = sub_relation?(name) && get_sub_relation(name)
    return sub_relation if sub_relation
    
		super
	end

  # Example:
  #   member.follows.clubs
  #   member.follows.lifes
  #   member.follows.pets
  #
  def has_relation?(name)
    raise "Not implemented yet."
  end

	def find doc_or_instance, selector_override, params_override
		# compose default selector
		# compose default params
		# Find and return results.
		  
		selector = self.selector
		params   = self.params

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
    child.find.by( final_selector ).and( final_params ) #.cache_in(instance)

	end # === find

  def map klass, results_arr
    _ids = results_arr.map { |doc| doc[foreign_key] }
    klass.find._id.in(_ids)
  end

  def has_relation? name
    sub_relations.has_key? name.to_sym
  end

  def get_relation name
    raise "Unknown relation: #{name.inspect}" unless has_relation?(name)
    sub_relations[name.to_sym]
  end

  def filter name, &blok
    sub_relations[name.to_sym] = \
      Mongo_Dsl::Relations_Liason.new( parent, type, name.to_sym, child_name, foreign_key, &blok ) 
  end
  
  def where field, value
    selector.update field.to_s => value
  end
  
  def where_in field, arr
    selector.update( field.to_s => { :$in => arr } )
  end

end # === class
