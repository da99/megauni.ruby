

class Failed_Log_In_Attempts

  include Couch_Plastic

  enable_timestamps
  
  make :body, :anything

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

  

end # === end Failed_Log_In_Attempts
