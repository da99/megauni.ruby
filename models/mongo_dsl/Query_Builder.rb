class Mongo_Dsl::Query_Builder
	
  attr_reader :model_klass, 
              :selector, 
              :params, 
              :current_field, 
              :instance

	def initialize model_klass
		@model_klass = model_klass
    @current_field = nil
    @selector    = {}
    @params      = {}
    @instance    = nil
	end
	
	def method_missing meth_name, *args
  
    super if args.size > 1

    value    = args.first
    name     = meth_name.to_s

    case meth_name
      when :by
        selector.update value
      when :and
        params.update value
      when :where
        selector[name] = value
      when :in
        selector[current_field] = { :$in => value }
    else
      if !@model_klass.allowed_field?(meth_name)
        super
      end
      
      if args.empty?
        @current_field = name
      else
        selector[name] = value
      end
    end
    
    self
    
	end

  def and_where condition_hash
    selector[current_field] ||={}
    selector[current_field].update condition_hash
  end

  def between start_, _end
    gte(start_).lt(_end)
  end

  %w{ gt gte lt lte }.each { |name|
    eval %~
      def #{name} val
        and_where :$#{name} => val
      end
    ~
  }

  def just_one?
    go!.size == 1
  end

  def first
    go!.first
  end

  def cache_in instance
    @instance = instance
  end

  def cacheable?
    !!instance
  end

  def cache_name
    [
      selector.keys, 
      selector.values, 
      params.keys, 
      params.values
    ].map(&:to_s).sort
  end

  def go
    model_klass.db.collection.find(selector, params)
  end

  def go!
    results = go.to_a
    instance.db.cache( cache_name, results ) if cacheable?
    results
  end
  
end # === class





