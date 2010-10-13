
class Mongo_Dsl::Query_Instance
  attr_reader :target,
              :selector, :params

  def initialize target
    @target = target
    @selector = {}
    @params   = {}
  end

  def want_request?(name)
    !!( 
       target.class.querys[name]
      )
  end

  def new_request list, name, *args
    list.querys << target.class.querys[name].clone
  end

  def go! list
    list.results << target
  end
  
end # === class


__END__

  # def _where field
  #   dyno_querys << [ :where, field ]
  #   self
  # end
  

