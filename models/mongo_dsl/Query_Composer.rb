
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

  # ==============================================================

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
  
  def first!
    results = go!
    raise "More than one result found." if results.size > 1
    results.first
  end

  def limit size
    params[:limit] = size
  end
  
  def sort val
    params[:sort] = val
  end
  
  def group_by val
    stack << { 
      :type => :group_by,
      :value => val.to_s
    }
  end

  def sort val
    stack.last[:params][:sort]  = val
  end

  def limit val
    stack.last[:params][:limit] = val
  end

end # === class Query_Composer


__END__

  # This method overrides any set
  #   :child_name and :foreign_key 
  #   
  # Therefore, ":Something, :some_id" is ignored in 
  # the following example:
  # 
  #   has_many :men, :Something, :some_id do
  #     based_on :people
  #     where :type, 'man'
  #   end
  #   
  def based_on relation_name
    ancestor        = parent.get_relation(relation_name)
    @child_name     = ancestor.child_name
    @foreign_key    = ancestor.foreign_key
    self.selector.update(ancestor.selector)
    self.params.update(ancestor.params)
    @dynamic_querys = ancestor.dynamic_querys
  end

