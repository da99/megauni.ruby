
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

  def where field, val
    selector[field] = val
    self
  end
   
end # === module 
