
module Uni_Array

  class << self
    
    def merge_with_namespace old, fresh, target, fk, name
      return old if old.empty? || fresh.empty?
      namespaced = fresh.inject( {} ) { |memo, doc| 
        
        new_doc = doc.inject({}) { |new_hsh, (key, val)|
          
          if key != '_id'
            new_hsh["#{name}_#{key}"] = val
          end
        
          new_hsh
        }

        memo[doc['_id']] = new_doc
        memo
      }

      
      if old.object_id == target.object_id
        old.each { |doc|
          doc.update namespaced[ doc[fk] ]
        }
      else
        old.each { |doc|
          target << doc.merge(namespaced[ doc[fk] ])
        }
      end
    end # === def merge_with_namespace
    
  end # === class self

  def method_missing name, *args
    
    return super unless args.empty?

    # Map of values.
    name_s = name.to_s
    single = name.to_s.sub(/s$/, '')
    return super if single == name_s
    
    @uni_cache ||= {}
    return @uni_cache[name] if @uni_cache.has_key?(name)
    
    are_docs = first.has_key?(single)
    if are_docs
      return( @uni_cache[name] = map { |doc| doc[single] } )
    end
    
    super
    
  end # === def method_missing

  def relationize arr, id_key, name
    Uni_Array.merge_with_namespace self, arr, [], id_key, name
  end

  def relationize! arr, id_key, name
    Uni_Array.merge_with_namespace self, arr, self, id_key, name
  end

end # === module Uni_Array

