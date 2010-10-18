

class Mongo_Dsl::Query_Class
  
  include Mongo_Dsl::Query_Common

  attr_reader :target,
              :selector, :params

  def initialize klass = nil
    @target      = klass
    @selector    = {}
    @params      = {}
  end

  def want_request?( composer, name )
    target.allowed_field?(name) ||
      target.querys[name] ||
        respond_to?( name )
  end
  
  def new_request( list, name, *args )
    if target.allowed_field?( name )
      return(selector[name] = args.first)
    end
    
    if target.querys[name]
      return( list.querys << target.querys[name].spawn! )
    end
    
    send( name, *args )
  end
  
  def where field, val
    selector[field] = val
    self
  end

  def go! composer
    composer.results << Mongo_Dsl.find( target.db.collection, selector, params ).to_a
  end

end # === class Query
