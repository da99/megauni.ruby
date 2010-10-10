
class Mongo_Dsl::Relations_Query_Builder
  
  attr_reader :model_klass, 
              :parent_instance,
              :stack,
              :current_klass

  def initialize instance
    @model_klass     = instance.class
    @parent_instance = instance
    @current_klass   = instance.class
    @stack           = [ { :type => :instance, :value => instance }]
  end

  def method_missing meth_name, *args
    
    super if args.size > 1
    
    name = meth_name.to_s
    val  = args.first

    case meth_name
    when :map 
      stack.last[:selector][:fields] = val
      stack << { :type => :map, :value => val }
    when :limit
      stack.last[:params][:limit] = val
    when :sort
      stack.last[:params][:sort]  = val
    else
      
      return super unless current_klass.relation?(meth_name)
      relation = current_klass.get_relation(meth_name)
      @current_klass = relation.child
      stack << {
        :type => :relation, 
        :name => meth_name,
        :selector => {},
        :params   => {},
        :value => relation
      }
      
    end # === case
      
    self

  end # === def method_missing

  def go!
    
    stack.inject( nil ) { |memo, meta|
      case meta[:type]
      when :instance
        meta[:value]
      when :relation 
        meta[:value].find(
          memo, meta[:selector], meta[:params]
        ).go!
      when :map
        memo.map { |doc|
          doc[meta[:value].to_s]
        }
      else
        raise "Unknown type: #{meta[:type].inspect}"
      end
		}
  end # === def go!
  
end # === class
