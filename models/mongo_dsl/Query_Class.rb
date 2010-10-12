

class Mongo_Dsl::Query_Class
  
  attr_reader :target,
              :selector, :params

  def initialize klass = nil
    @target      = klass
    @selector    = {}
    @params      = {}
  end

  def want_request?( name )
    case name
    when :_id
      true
    else
      false
    end
  end
  
  def new_request( list, name, *args )
    case name
    when :_id
      selector[name] = args.first
    else
      raise "Unknown request: #{name.inspect}, #{args.inspect}"
    end
  end
  
  def where field, val
    selector[field] = val
    self
  end

end # === class Query
