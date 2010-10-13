
module Mongo_Dsl::Query_Common

  def between start_ , _end
    gte(start_).lt(_end)
  end

  %w{ gt gte lt lte }.each { |name|
    eval %~
      def #{name} raw_field, val
        field = raw_field.to_sym
        selector[field] ||= {}
        selector[field][:$#{name}] = val
        self
      end
    ~
  }

  def limit size
    params[:limit] = size
    self
  end
  
  def sort val
    params[:sort] = val
    self
  end
  
  def where_in field, val
    selector[field] = { :$in => val }
    self
  end

  def _where field
    dyno_querys << [ :where, field ]
    self
  end

  def where field, val
    selector[field] = val
    self
  end

	# Only applies to Query_Relate and Query_Relate::Spawn
	# objects.
  def foreign_key *args
    return @foreign_key if args.empty?
    
    # Remove old foreign_key.
    if foreign_key 
      @dyno_querys = dyno_querys.select { |quer|
        quer != [:where, foreign_key]
      }
    end
    
    # Add new foreign_key.
    @foreign_key = args.first
    if foreign_key
      _where foreign_key
    end
    
  end
   
end # === module 
