
module Mongo_Dsl::Query_Common

  def method_missing name, *args
    return super unless child.allowed_field?(name)
    where name, *args
  end

  def between start_ , _end
    gte(start_).lt(_end)
  end

  %w{ gt gte lt lte }.each { |name|
    eval %~
      def #{name} val
        field = current_field
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
  
  # Either 1) a key to sort by
  # or 2) an array of [key, direction] pairs to sort by. 
  #    Direction should be specified as 
  #    Mongo::ASCENDING (or :ascending / :asc) or 
  #    Mongo::DESCENDING (or :descending / :desc) 
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
    if @foreign_key 
      @dyno_querys = dyno_querys.select { |quer|
        quer != [:where, @foreign_key.to_sym] ||
        quer != [:where, @foreign_key.to_s]
      }
    end
    
    if type == :belongs_to
      @dyno_querys = dyno_querys.select { |quer|
        quer != [:where, '_id'] ||
        quer != [:where, :_id]
      }
    end
    
    # Add new foreign_key.
    @foreign_key = args.first
    
    if type == :belongs_to
      _where :_id
    else
      _where @foreign_key
    end
    
  end # === def
  
  def fields *raw_flds
    params[:fields] =  (raw_flds + ['_id']).
      flatten.
      compact.
      uniq.
      map(&:to_s) 
    
    self
  end

   
end # === module 
