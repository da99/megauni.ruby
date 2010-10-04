

class Life

  include Couch_Plastic
  enable_timestamps

  CATEGORIES = %w{ real celebrity pet baby fantasy }

  make :owner_id, :mongo_object_id, [:in_array, lambda { manipulator.username_ids } ]
  make :username, 
    # Delete invalid characters and 
    # reduce any suspicious characters. 
    # '..*' becomes '.'
    [:stripped, /[^a-z0-9_-]{1,}/i, lambda { |s|
        if ['.'].include?( s[0,1] )
          s[0,1]
        else
          ''
        end
      }], 
     [:min, 2, 'Username is too small. It must be at least 2 characters long.'],
     [:max, 20, 'Username is too large. The maximum limit is: 20 characters.'],
     [:not_match, /[^a-zA-Z0-9\.\_\-]/, 'Username can only contain the follow characters: A-Z a-z 0-9 . _ -']
  #VALID_USERNAME_FORMAT = /\A[a-zA-Z0-9\-\_\.]{2,25}\z/
  #VALID_USERNAME_FORMAT_IN_WORDS = "letters, numbers, underscores, dashes and periods."
  
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
