
class Mongo_Dsl::Query_Instance
  
  attr_reader :target,
              :selector, :params

  def initialize target
    @target = target
    @selector = {}
    @params   = {}
    freeze
  end

  def want_request?(composer, name)
    !!( 
       target.class.querys[name]
      )
  end

  def new_request composer, name, *args
    composer.querys << target.class.querys[name].spawn!
  end

  def go! composer
    composer.results << target
  end

end # === class


