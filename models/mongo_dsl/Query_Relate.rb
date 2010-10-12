
class Mongo_Dsl::Query_Relate
  attr_reader :parent, :child,
              :selector, :params, :dyno_querys, :filters
  
  def initialize parent, child_name
    @parent      = parent
    @child       = eval(child_name.to_s)
    @dyno_querys = []
    @filters     = {}
    @selector    = {}
    @params      = {}
  end
  
  def want_request? name
    !!(
      filters[name] ||
        child.querys[ name ]
    )
  end
  
  def new_request composer, name, *args
    if filters[name]
      composer.querys.pop
      composer.querys << filters[name].dup
    else
      composer.querys << child.querys[name].dup
    end
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
  
end # === class Query_Base
