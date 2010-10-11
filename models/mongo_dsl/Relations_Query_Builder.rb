
class Mongo_Dsl::Relations_Query_Builder
  
  attr_reader :model_klass, 
              :parent_instance,
              :stack,
              :relation_stack,
              :current_klass

  def initialize instance
    @model_klass     = instance.class
    @parent_instance = instance
    @current_klass   = instance.class
    @stack           = [ { :type => :instance, :value => instance }]
    @relation_stack  = []
  end

  def unshift_klass klass, instance = nil
    @klass_stack << {:klass => klass, :instance => instance}
  end

  def method_missing meth_name, *args
    
    super if args.size > 1
    
    name = meth_name.to_s
    val  = args.first

    return super unless current_klass.has_relation?(meth_name)
    relation = current_klass.get_relation(meth_name)
    @current_klass = relation.child
    stack << {
      :type => :relation, 
      :name => meth_name,
      :selector => {},
      :params   => {},
      :value => relation
    }
    @relation_stack << relation
      
    self

  end # === def method_missing

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

  # Allowed usage:
  #   lifes.follows.clubs.grab(Klass).go!
  #   lifes.follows.clubs.map(:follower_id).grab(Club).go!
  #
  def grab klass
    # Make sure we insert before any :group_by or :map operations.
    # We want to grab the docs wehn the results is an array of docs.
    # :group_by and :map turn the array into either Hashes or an
    #   Array of non-docs: [ ObjectID, ObjectId, etc. ]
    #   that will lead to runtime errors.
    index = (0...(stack.length)).to_a.reverse.detect { |ind|
      !stack[ind].is_a?(Hash) ||
        ![ :group_by, :map ].include?( stack[:type] )
    }
    stack[index..1] = { :type => :grab, :value => klass }
  end

  def map val
    stack.last[:selector][:fields] = val
    stack << { :type => :map, :value => val }
  end

  def go!
    
    stack.inject( nil ) { |memo, meta|
      case meta[:type]
      when :instance
        meta[:value]
        
      when :relation 
        meta[:value].find(
          memo, meta[:selector], meta[:params]
        ).go!
        
      when :group_by
        memo.inject({}) { |new_hash, doc|
          new_hash[meta[:value]] = doc
        }
        
      when :map
        memo.map { |doc|
          doc[meta[:value].to_s]
        }
        
      when :grab
        # 
        # Example:
        #   [ { :fk => 1, :fk2 => 2 },
        #     { :fk => 1, :fk2 => 2 }
        #   ]
        # using "grab( Klass )" becomes:
        #   [ { :title => title, :body => body },
        #     { :title => title, :body => body } 
        #   ]
        # 
        doc_klass = meta[:value]
        relation = relation_stack.last.get_relation( doc_klass )
        fk       = relation.foreign_key
        relation.map( doc_klass, memo ).go!
        
      else
        raise "Unknown type: #{meta[:type].inspect}"
      end
		}
  end # === def go!
  
end # === class
