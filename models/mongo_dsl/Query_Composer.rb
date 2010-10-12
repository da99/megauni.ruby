
class Mongo_Dsl::Query_Composer

  attr_reader :querys, :results, :after_all
  
  def initialize target
    @querys   = []
    @results  = []
    @after_all = []
    
    if target.respond_to?(:included_modules)
      querys << Query_Class.new(target)
    else
      querys << Query_Instance.new(target)
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
    querys.last.selector[:fields] = field.to_s
    after_all << [:map, field.to_s]
    self
  end

  def grab name
    method_missing name
    self
  end

  def go!
    %w{ results querys after_all }.each { |meth|
      
      puts "#{meth}:"
      pp send(meth)

    }
    
    puts "\n"
    puts "\n"
  end


end # === class Query_Composer
