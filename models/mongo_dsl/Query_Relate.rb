require 'modules/To_Class'

class Mongo_Dsl::Query_Relate
  
  include Mongo_Dsl::Query_Common
  
  attr_reader :parent, :child,
              :type, :name, :child_name, :foreign_key,
              :selector, :params, :dyno_querys, :filters, :pending_overrides
  
  def initialize parent, type, name, child_name, foreign_key, &blok
    
    # Initialize properties.
    @parent      = parent
    @foreign_key = foreign_key
    @child       = nil
    @child       = child_name.respond_to?(:included_modules) ? child_name : nil
    @child_name  = @child ? @child.to_s : \
      begin
        name.extend To_Class
        name.to_model_class_name
      end
    
    # Initialize stacks/containers.
    @dyno_querys = []
    @filters     = {}
    @selector    = {}
    @params      = {}
    @pending_overrides = []

    # Initialize other properties.
    instance_eval(&blok) if block_given?
    
    # Check if there were any overrides.
    origin         = self
    override_count = 
    
    pending_overrides.size.times { 
      ovr  = pending_overrides.unshift
      name = ovr.first
      blok = ovr.last
      
      relate = origin.dup
      relate.instance_eval &blok
      origin.filters << relate
    }
    
  end # def initialize
  
  def child
    @child || begin
      raise "child_name is empty: #{self.inspect}" if child_name.to_s.empty?
      klass = child_name.to_s.extend(String_To_Class).to_class
      @child = klass unless frozen?
      klass
    end
  end

  def want_request? name
    !!(
      filters[name] ||
        child.querys[ name ] ||
          respond_to?(name)
    )
  end
  
  def new_request composer, name, *args
    if filters[name]
      composer.querys.pop
      composer.querys << filters[name].dup
    elsif child.querys[name]
      composer.querys << child.querys[name].dup
    else
      send( name, *args )
    end
  end

  def overrides_as name, &blok
    pending_overrides << [name, blok]
  end

  def override name
    filters[name] = clone
  end

  def _where field
    dyno_querys << [ :where, field ]
    self
  end

  def where field, val
    selector[field] = val
    self
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
end # === class Query_Base
