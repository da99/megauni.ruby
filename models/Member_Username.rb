

class Member_Username

  include Couch_Plastic

  enable_timestamps
  
  make :owner_id, :mongo_object_id, [:in_array, lambda { manipulator.lifes._ids } ]
  make :username, [:min, 2, "Username is too small."]
  make :title, [:min, 1]

  def self.by_id(id)
    orig = super(id)
    return orig unless orig
    if not orig.data.title
      orig.data.title = "The Universe of #{data.username}"
    end
    orig
  end

  # ==== Authorizations ====
 
  def owner? mem
    data.owner_id == mem ||
      (mem.respond_to?(:data) && mem.data._id == data.owner_id)
  end

  def allow_as_creator? editor # NEW, CREATE
    return false if !editor.is_a?(Member)
    true
  end

  def reader? editor # SHOW
    owner?(editor)
  end

  def updator? editor # EDIT, UPDATE
    owner?(editor)
  end

  def deletor? editor # DELETE
    owner?(editor)
  end

  # ==== Accessors ====

  def href
    "/life/#{data.username}/"
  end

end # === end Member_Username
