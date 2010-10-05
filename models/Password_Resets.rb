

class Password_Resets

  include Couch_Plastic

  enable_timestamps
  
  make :body, :anything

  # ==== Class Methods ====
  
  class << self
    def by_member mem
      reset_id = "#{mem.data._id}-password-reset"
    end
  end

  # ==== Authorizations ====
 
  def allow_as_creator? editor # NEW, CREATE
  end

  def reader? editor # SHOW
  end

  def updator? editor # EDIT, UPDATE
  end

  def deletor? editor # DELETE
  end

  # ==== Accessors ====

  

end # === end Password_Resets
