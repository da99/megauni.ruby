class Mongo_Dsl::Query_Builder
	
  attr_reader :model_klass, :selector, :params, :current_field

	def initialize model_klass
		@model_klass = model_klass
    @current_field = nil
    @selector    = {}
    @params      = {}
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

  def go!
    [ model_klass, selector, params ]
    (0..3).to_a.map { |index|
      doc = {}
      model_klass::FIELDS.each { |fld|
        doc[fld] = "#{model_klass}-#{index}-#{fld}" 
      }
      doc
    }
  end
  
end # === class
