require 'models/Delegator_Dsl'
require 'modules/To_Class'
require 'modules/Uni_Array'

class Mongo_Dsl::Query_Relate
  
  include Mongo_Dsl::Query_Common
  
  attr_reader :parent, 
              :type, :name, :child_name, 
              :selector, :params, :dyno_querys, :filters, 
              :overrides, :pending_overrides
  
  def initialize parent, type, name, child_name, foreign_key, &blok
    
    # Initialize properties.
    @name        = name
    @type        = type
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
    
    @filters     = {}
    @selector    = {}
    @params      = {}
    @pending_overrides = []
    @overrides = []

    # Initialize other properties.
    instance_eval(&blok) if block_given?
    
    if !self.foreign_key
      self.foreign_key "#{name.to_s.dup.extend(To_Class).to_singular}_id"
    else
      self.foreign_key @foreign_key
    end
    
    # Check if there were any overrides.
    origin         = self
    
    pending_overrides.size.times { 
      ovr  = pending_overrides.shift
      name = ovr.first
      blok = ovr.last
      
      relate = spawn!
      relate.instance_variable_set '@name', name
      relate.instance_eval( &blok )
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
  
  attr_reader :origin, :selector, :params, :dyno_querys, 
              :filters, :do_as_merge, :name
  
  def initialize origin, allowed_ivars = []
    @origin   = origin
    @do_as_merge = false
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
  
  def do_as_merge
    @do_as_merge = true
  end
  
  def merge?
    @do_as_merge
  end

  def want_request? composer, name
    !!(
      filters[name] ||
          respond_to?(name) ||
          (origin.child.querys[ name ] && composer.grabs.include?(name) || composer.merges.include?(name)) 
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
    id_key = case type
             when :has_many
                '_id'
             when :belongs_to
               foreign_key
             else
               raise "not ready for: #{type.inspect}"
             end
    
    ids = case results
          when Array
            results.map { |doc| 
              doc[id_key]
            }
          when Hash
            results[id_key]
          else
            results.fetch(id_key)
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

    
    new_results = Mongo_Dsl.find( child.db.collection, selector, params ).to_a
    
    # Do we combine the new results with the previous results
    # using a namespace?
    # 
    if merge?
      results.extend Uni_Array
      results.relationize! new_results, id_key, name
    else
      composer.results << new_results
    end
    
  end
  
  def spawn(new_name)
    Spawn.new(self, new_name)
  end

end # === class Spawn


