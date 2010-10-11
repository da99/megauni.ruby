
class Mongo_Dsl::Relations_Liason
	
  DYNO_Q = :dyno_q

	class << self
		
		def relations 
			@relations ||= {}
		end

		def new_relation parent, type, name, child, foreign_key
			relations[parent] ||= {}
			relations[parent][name] = new( parent, type, name, child, foreign_key )
		end
		
    def has_relation?(parent, name)
      !!( relations[parent] && relations[parent][name] )
    end

		def get_relation parent, name
			relations[parent][name]
		end
		
	end # === self

	attr_reader :parent, :type, :name, :child_name, :foreign_key, 
              :instance, :sub_relations,
              :selector, :params,
              :dynamic_querys
	
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
    @dynamic_querys = []

    instance_eval(&blok) if block_given?
	end
  
  def child
    @Class_as_Object ||= Object.const_get(child_name.to_s.to_sym)
  end

	def method_missing name, *args
    return super if !args.empty?

    if self.class.has_relation?( child, name )
		  return self.class.get_relation( child, name )
    end
   
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
    store_instance(doc_or_instance)
    
    dynamic_querys.each { |query|
      action, field = query
      case action
      when :where
        selector[field] = extract_value( field, doc_or_instance)
      when :where_in
        selector[field] = { :$in => extract_value( field, doc_or_instance ) }
      else 
        raise "Unknown action: #{action.inspect}"
      end
    }

    
		case type
		when :has_many
			selector[foreign_key] = extract_value( foreign_key, doc_or_instance ) 
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

  def store_instance doc_or_instance
    case doc_or_instance
    when Hash
    when Array
    else 
      @instance = doc_or_instance
    end
  end

  def extract_value foreign_key, doc_or_instance
    case doc_or_instance
    when Hash
      doc_or_instance[foreign_key] || doc_or_instance[foreign_key.to_sym]
    when Array
      doc_or_instance.map { |doc| 
        if doc.respond_to?(:data)
          doc.data._id
        elsif doc.is_a?(Hash)
          doc[foreign_key]
        else
          doc
        end
      }
    else
      instance.data._id
    end
  end # === def 

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
  
  def where field, value = DYNO_Q
    if field.is_a?(Hash) || field.is_a?(Array)
      raise ArgumentError, "Invalid field: #{field.inspect}" 
    end
    
    if value == DYNO_Q
      dynamic_querys << [:where, field]
    else
      selector[field.to_s] = value
    end
  end
  
  def where_in field, arr = DYNO_Q
    if field.is_a?(Hash) || field.is_a?(Array)
      raise ArgumentError, "Invalid field: #{field.inspect}" 
    end
    
    if arr == DYNO_Q
      dynamic_querys << [:where_in, field]
    else
    end
    selector[ field.to_s ] =  { :$in => arr }
  end

  def limit size
    params[:limit] = size
  end
  
  def sort val
    params[:sort] = val
  end
  
  def based_on relation_name
    ancestor = parent.get_relation(relation_name)
    @class_name ||= ancestor.child_name
    @foreign_key ||= ancestor.foreign_key
    self.selector.update(ancestor.selector)
    self.params.update(ancestor.params)
    @dynamic_querys = ancestor.dynamic_querys
  end

end # === class
