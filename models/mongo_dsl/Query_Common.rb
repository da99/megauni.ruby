
module Mongo_Dsl::Query_Common

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

  def limit size
    params[:limit] = size
  end
  
  def sort val
    params[:sort] = val
  end

end # === module 
