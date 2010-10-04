

class Life

  include Couch_Plastic
  enable_timestamps

  CATEGORIES = %w{ real celebrity pet baby fantasy }

  make :owner_id, :mongo_object_id, [:in_array, lambda { manipulator.username_ids } ]
  make :username, [:min, 2, "Username is too small."]
	make :category, [:in_array, CATEGORIES]

  # ==== Hooks ====

  # ==== Authorizations ====
 
  def owner? mem
    data.owner_id == mem ||
      (mem.respond_to?(:data) && mem.data._id == data.owner_id)
  end

  def allow_as_creator? editor # NEW, CREATE
    return false if !editor.is_a?(Member)
    true
  end

  def self.create editor, raw_raw_data # CREATE
    new do
			self.manipulator = editor
			self.raw_data = raw_raw_data
			demand :owner_id, :username, :category
			save_create
		end
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

  # ==== Validators ====

end # === end Life
