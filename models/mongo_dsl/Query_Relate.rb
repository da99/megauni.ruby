require 'models/Delegator_Dsl'
require 'modules/To_Class'

class Mongo_Dsl::Query_Relate
  
  include Mongo_Dsl::Query_Common
  
  attr_reader :parent, :child,
              :type, :name, :child_name, 
              :selector, :params, :dyno_querys, :filters, 
              :overrides, :pending_overrides
  
  def initialize parent, type, name, child_name, foreign_key, &blok
    
    # Initialize properties.
    @name        = name
    @parent      = parent
    @foreign_key = foreign_key
    
    @child       = nil
    @child       = child_name.respond_to?(:included_modules) ? child_name : nil
    @child_name  = if @child
                     child.to_s.to_sym
                   elsif child_name
                     child_name.to_s  
                   else
                     name.to_s.extend(To_Class).to_model_class_name
                   end
    
    # Initialize stacks/containers.
    @dyno_querys = []
    if foreign_key
      _where foreign_key
    end
    
    @filters     = {}
    @selector    = {}
    @params      = {}
    @pending_overrides = []
    @overrides = []

    # Initialize other properties.
    instance_eval(&blok) if block_given?
    
    # Check if there were any overrides.
    origin         = self
    
    pending_overrides.size.times { 
      ovr  = pending_overrides.shift
      name = ovr.first
      blok = ovr.last
      
      relate = spawn!
      relate.instance_variable_set '@name', name
      relate.instance_eval &blok
      # origin.overrides << relate
      origin.parent.relations[name] = relate
    }
    overrides.freeze
    
    # Check if there were any filters (aka sub-queries).
    filters.keys.each { |name|
      filt = filters[name]
      unless filt.is_a?(Mongo_Dsl::Query_Relate) 
        dupi = spawn!
        dupi.instance_variable_set '@name', name
        dupi.instance_eval( &filt )
        filters[name] = dupi
      end
    }
    
    filters.freeze
    
  end # def initialize
  
  def child
    @child || begin
      raise "child_name is empty: #{self.inspect}" if child_name.to_s.empty?
      klass = child_name.to_s.extend(String_To_Class).to_class
      @child = klass unless frozen?
      klass
    end
  end

  def override_as name, &blok
    pending_overrides << [name, blok]
  end

  def filter name, &blok
    filters[name] = blok
  end

  def _find doc_or_instance, selector_override, params_override
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
  
  def spawn!
    Spawn.new(self, ['@name'])
  end

end # === class Query_Base




# ====================================================================
class Mongo_Dsl::Query_Relate::Spawn
  
  extend Delegator_Dsl
  delegate_to :origin, 
              :parent, :type, :child_name, :child
  
  include Mongo_Dsl::Query_Common
  
  attr_reader :origin, :selector, :params, :dyno_querys, :filters
  
  def initialize origin, allowed_ivars = []
    @origin = origin
    ivars_to_dup = (allowed_ivars + %w{ @selector @foreign_key @params @dyno_querys @filters })
    ivars_to_dup.each { |attr|
      new_val = origin.instance_variable_get(attr)
      val = begin
              new_val.dup
            rescue TypeError
              new_val
            end
      instance_variable_set attr, val
    }
  end
  
  def want_request? name
    !!(
      filters[name] ||
        origin.child.querys[ name ] ||
          respond_to?(name)
    )
  end
  
  def new_request composer, name, *args
    if filters[name]
      composer.querys.pop
      composer.querys << filters[name].spawn!
    elsif child.querys[name]
      composer.querys << child.querys[name].spawn!
    else
      send( name, *args )
    end
  end
  
  def spawn!
    self.class.new(self, ['@name'])
  end
  
  def go! composer
    results = composer.results.last

    # Let's compile the results into
    # something this relation can use.
    ids = case results
          when Array
            results.map { |doc| 
              doc['_id']
            }
          when Hash
            results['_id']
          else
            results.fetch('_id')
          end

    # We got the stuff for dynamic queries.
    # Let's "compile" them into :selector
    relate = self
    dyno_querys.each { |quer|
      case quer.first
      when :where
        relate.selector[quer.last] = case ids
                                     when Array
                                       { :$in => ids }
                                     else
                                       ids
                                     end
      else
        raise "Unknown dynamic query: #{quer.inspect}"
      end
    }

    composer.results << child.db.collection.find(selector, params).to_a
  end
  
  def spawn(new_name)
    Spawn.new(self, new_name)
  end

end # === class Spawn
