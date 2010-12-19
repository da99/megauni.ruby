
module Mongo_Dsl
  


  # =========================================================================
  module Class_Methods # ====================================================
  # =========================================================================
  end


end # === module Mongo_Dsl ================================================

%w{
  Db
  Query_Common
  Query_Composer
    Query_Class
    Query_Instance
      Query_Relate
}.each { |doc|
  require "models/mongo_dsl/#{doc}"
}



__END__



    # Example:
    #    arr = [ doc, doc, doc ]
    #    relationaize arr, Life, 'owner_id', 'username'=>'owner_username'
    # Each doc now has 'owner_username' added to it
    # from the Life class.
    # 
    # To include the entire doc, use a map of
    #     'key_name' => :doc
    #
    # Parameters: 
    #   fk => means foreign key
    #   field_map =>
    #      { 'username' => 'owner_username' }
    #    
    def relationize raw_coll, relation_class, fk, field_map
      coll   = raw_coll.to_a
      fks    = coll.map { |doc| doc[fk] }.uniq.compact
      f_docs = relation_class.find(:_id=>{ :$in => fks }).inject({}) { |m, doc|
        m[doc['_id']] = doc
        m
      }
      
      coll.map { |doc|
        target = f_docs[doc[fk]]
        field_map.each { | orig, namespaced |
          if namespaced == :doc
            doc[orig] = target
          else
            doc[namespaced] = if target
                                target[orig]
                              else
                                nil
                              end
          end
        }
        doc
      }
    end

