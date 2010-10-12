

class Mongo_Dsl::Query_Class
  
  include Mongo_Dsl::Query_Common

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
      respond_to? name 
    end
  end
  
  def new_request( list, name, *args )
    case name
    when :_id
      selector[name] = args.first
    else
      send( name, *args )
    end
  end
  
  def where field, val
    selector[field] = val
    self
  end

end # === class Query
