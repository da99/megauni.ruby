
class Mongo_Dsl::Query_Composer

  attr_reader :querys, :results, :after_all
  
  def initialize target
    @querys    = []
    @results   = []
    @after_all = []
    
    if target.respond_to?(:included_modules)
      querys << Mongo_Dsl::Query_Class.new(target)
    else
      querys << Mongo_Dsl::Query_Instance.new(target)
    end
  end

  def method_missing name, *args
    
    if not after_all.empty?
      raise "Can't add any more queries once :after_all is no longer empty."
    end

    if querys.last && querys.last.want_request?( name )
      querys.last.new_request( self, name, *args )
      return self
    end
    
    super
  end # def method_missing

  def map field
    querys.last.params[:fields] = field.to_s
    after_all << [:map, field.to_s]
    self
  end

  def grab name
    method_missing name
    self
  end

  def go!
    # Grab results
    composer = self
    querys.each { |quer|
      quer.go!( composer )
    }
    
    
    # Post processing.
    after_all.size.times { |index|
      answer = results.last
      
      action, val = after_all.shift
      
      new_answer = case action
                   when :map
                     answer.map { |doc| doc.fetch(val) }
                   when :group_by
                     answer.inject( {} ) { |memo, doc|
                       memo[val] = doc
                       memo
                     }
                   else
                     raise "Unknown action: #{action.inspect}"
                   end
      
      composer.results << new_answer
    }
    
    results.last
    
  end

  # ==============================================================

  def go_first!
    results = go!
    raise "More than one result found." if results.size > 1
    raise Mongo_Dsl::Not_Found, "#{querys.last.selector.inspect}" if results.size < 1
    results.first
  end
  
  def group_by val
    after_all << [:group_by, val.to_s]
  end

end # === class Query_Composer


__END__



