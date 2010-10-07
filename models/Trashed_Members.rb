

class Trashed_Members

  include Couch_Plastic

  enable_timestamps
  
  make :_id, :mongo_object_id
  make :doc, :anything

  # ==== Authorizations ====
 
  class << self
    
    def create editor, raw_raw_data
      super.instance_eval do
        demand :doc
        set_id new_data.doc['_id']
        save_create
      end
    end

  end # === self

  def allow_to? action, editor
    case action
    when :create
    when :read
    when :update
    when :delete
    end
  end


  # ==== Accessors ====

  

end # === end Trashed_Members
