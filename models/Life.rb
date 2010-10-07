

class Life

  include Couch_Plastic

  CATEGORIES = %w{ real celebrity pet baby fantasy }
	HREF_NAMESPACE = '/life'
	HREF_PATTERN = [ '/life/%s/', :username]

  enable_timestamps
	make :owner_id, :mongo_object_id, [:in_array, lambda { manipulator.lifes._ids } ]
  make :title, :anything
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
	  
  # ==== Associations   ====
	
	belongs_to :owner, Member
  # def owner? mem
  #   data.owner_id == mem ||
  #     (mem.respond_to?(:data) && mem.data._id == data.owner_id)
  # end

  # ==== Authorizations ====
 

	def allow_to? action, editor
		case action
			when :create
				return false if !editor.is_a?(Member)
				true
			when :read
				owner?(editor)
			when :update
				owner?(editor)
			when :delete
				owner?(editor)
		end
	end

	class << self
		def create editor, raw_raw_data # CREATE
			super.instance_eval do
				demand :owner_id, :username, :category
				save_create
			end
		end
	end # == self


  # ==== Accessors ====

  def href
    "/life/#{data.username}/"
  end

  # ==== Validators ====

	module Results
		
		# Returns: 
		#   Hash
		#     :username_id => username
		#     :username_id => username
		#     :username_id => username
		#
		def _ids_to_usernames
			@ids_to_usernames_hash ||= \
				inject({}) { |hsh, un| 
					hsh[un['_id']] = begin
														 un['username'].extend Username_Results
														 un['username']
													 end
					hsh
				}
		end
		
		# Returns: 
		#   Hash
		#     :username_id => username
		#     :username_id => username
		#     :username_id => username
		#
		def usernames_to_ids
			@usernames_to_ids ||= _ids_to_usernames.invert
		end
		
		#	Returns:
		#   Array - [ :username_id ]
		#
		def _ids *str
			_ids_to_usernames.keys
		end
		
		# Accepts:
		#		str - Optional. Username as String.
		#
		# Returns: 
		#		nil 
		#		BSON:ObjectID
		#		
		def _id_for str
				_ids_to_usernames.index(str)
		end

	
		def usernames
			_ids_to_usernames.values
		end

		# Accepts:
		#		raw_id - BSON::ObjectID or legal String
		#						 to be turned into a BSON::ObjectID.
		#
		# Returns: 
		#		nil or String.
		#		
		def username_for raw_id
			id = Couch_Plastic.mongofy_id(raw_id)
			_ids_to_usernames[id]
		end

		# Accepts:
		#   un_ids - Optional. Array [
		#     username_id
		#     username_id
		#   ]
		#
		# Returns:
		#   Array - [
		#     { 
		#       'username_id'   => id, 
		#       'username'      => un, 
		#       'selected?'     => Boolean,
		#       'not_selected?' => Boolean
		#     }
		#   ]
		#
		def menu un_ids = []
			_ids_to_usernames.map { |id, un|
				{ 
					'username_id'   => id,
					'username'      => un,
					'href'      => Life.href_for(un),
					'selected?'     => un_ids.include?(id),
					'not_selected?' => !un_ids.include?(id)
				}
			}
		end

	end # === module Results
	
	module Username_Results

		def href
			Life.href_for self
		end
		
	end # === module 
	
end # === end Life
