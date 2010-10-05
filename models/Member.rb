require 'bcrypt'

class Member 

  attr_reader :password_reset_code
  
  include Couch_Plastic

  # =========================================================
  #                     CONSTANTS
  # =========================================================  
  
  Wrong_Password              = Class.new( StandardError )
  Password_Reset              = Class.new( StandardError )
  Password_Not_In_Reset       = Class.new( StandardError )
  Invalid_Password_Reset_Code = Class.new( StandardError )
  Invalid_Security_Level      = Class.new( StandardError )

  SECURITY_LEVELS        = %w{ NO_ACCESS STRANGER  MEMBER  EDITOR   ADMIN }
  SECURITY_LEVELS.each do |k|
    const_set k, k
  end
  
  EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/

	has_one :password_reset
	has_many :lifes
	
  enable_timestamps
  make :hashed_password, :not_empty
  make :salt, :not_empty 
  make :security_level, [:in_array, SECURITY_LEVELS]
  
  make :email, 
    :string,
    [:stripped, /[^a-z0-9\.\-\_\+\@]/i ],
    [:match, /\A[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]\Z/ ],
    [:min, 6],
    [:equal, lambda { raw_data.email } ],
    [:error_msg, 'Email has invalid characters.']

	make_psuedo :update_username, :not_empty
	make_psuedo :confirm_password, :not_empty
	make_psuedo :password, 
      :not_empty,
      [:min, 5],
      [:equal, lambda { self.raw_data.confirm_password }, 'Password and password confirmation do not match.' ],
      # [:match, /[0-9]/, 'Password must have at least one number' ],
      [:if_no_errors, lambda {
          new_data.salt = begin
                            # Salt and encrypt values.
                            chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
                            (1..10).inject('') { |new_pass, i|  
                              new_pass += chars[rand(chars.size-1)] 
                              new_pass
                            }
                          end

          new_data.hashed_password = BCrypt::Password.create( cleanest(:password) + new_data.salt ).to_s
      }]
  # ==== Class Methods =====================================================    

  def self.delete id, editor
    obj = begin
            by_id(id)
          rescue Member::Not_Found
            nil
          end
    if obj
      super(id, editor)
      Trashed_Members.create(editor, obj.data.as_hash)
    end
    obj
  end

  def self.valid_security_level?(perm_level)
    return true if SECURITY_LEVELS.include?(perm_level)
    case perm_level
    when BSON::ObjectID, Member, String, Symbol
      true
    else
      false
    end
  end

  # ==== Getters =====================================================    
  
  def self.add_docs_by_username_id(docs, key = 'owner_id')
    
    # Grab all docs for: usernames, members.
    editor_ids = docs.map { |doc| doc[key] }.compact.uniq
    lifes  = Life.find(:owner_id => { :$in => editor_ids } ).to_a
    member_ids = lifes.map { |doc| doc['owner_id'] }
    members    = Member.all_by_id( :$in  => member_ids ).to_a
    
    # Create a Hash: :username_id => :username
    username_map = lifes.inject({}) { |memo, un|
      memo[un['_id']] = un['username']
      memo
    }
    
    # Create a Hash: :username_id => :member
    editor_map = editor_ids.inject({}) do |memo, ed_id|
      memo[ed_id] = members.detect { |mem| 
                      mem['_id'].to_s == ed_id.to_s
                    }
      memo
    end
    
    # Finally, add corresponding member to target collection.
    key_username = key.sub('_id', '_username')
    key_mem      = key.sub('_id', '')
    docs.each { |doc|
      un_id = doc[key]
      doc[key_username] = username_map[ un_id ]
      doc[key_mem]       = editor_map[ un_id ]
    }
    
  end

  def self.by_email email
    mem = find_one(:email=>email)
    if email.empty? || !mem
      raise Not_Found, "Member email: #{email.inspect}"
    end
    Member.by_id(mem['_id'])
  end
  
  # Based on Sinatra-authentication (on github).
  # 
  # Parameters:
  #   raw_vals - Hash with at least 2 keys: :username, :password
  # 
  # Raises: 
  #   Member::Wrong_Password
  #
  def self.authenticate( raw_vals )

    username   = (raw_vals[:username] || raw_vals['username']).to_s.strip
    password   = (raw_vals[:password] || raw_vals['password']).to_s.strip
    ip_addr    = (raw_vals[:ip_address] || raw_vals['ip_address']).to_s.strip
    user_agent = (raw_vals[:user_agent] || raw_vals['user_agent']).to_s.strip
    
    ip_addr    = nil if ip_addr.empty?
    user_agent = nil if user_agent.empty?

    if username.empty? || password.empty?
      raise Wrong_Password, "#{raw_vals.inspect}"
    end

		life = Life.by_username( username )
    mem = life.owner

    # Check for Password_Reset
    raise Password_Reset, mem.inspect if mem.password_in_reset?

    # See if password matches with correct password.
    correct_password = BCrypt::Password.new(mem.data.hashed_password) === (password + mem.data.salt)
    return mem if correct_password

    # Grab failed attempt count.
    fail_count = Failed_Log_In_Attempts.for_today(mem).count
    new_count  = fail_count + 1
    
    # Insert failed password.
    Failed_Log_In_Attempts.create(
			nil,
      { :data_model => 'Member_Failed_Attempt',
      :owner_id   => mem.data._id, 
      :date       => Couch_Plastic.utc_date_now, 
      :time       => Couch_Plastic.utc_time_now,
      :created_at => Couch_Plastic.utc_now,
      :ip_address => ip_addr,
      :user_agent => user_agent }
    )

    # Raise Account::Reset if necessary.
    if new_count > 2
      mem.reset_password
      raise Password_Reset, mem.inspect
    end

    raise Wrong_Password, "Password is invalid for: #{username.inspect}"
  end 


  # ==== Authorizations ====

  def allow_as_creator? editor # NEW, CREATE
    return true if !editor
    false
  end

  def self.create editor, raw_raw_data # CREATE
    d = new do
      self.manipulator = editor
      self.raw_data = raw_raw_data
      
      new_data.security_level = Member::MEMBER
      ask_for :email
      demand  :add_username, :password
			generate_id
			save_create_life
			save_create
    end
  end

	def save_create_life
		return false unless creatable?
		
		begin
			life = Life.create( self, 
												 :username   => clean_data.add_username,  
												 :owner_id   => data._id || cleanest(:_id)
												)
			
		rescue Life::Invalid
			errors.concat $!.doc.errors
		end
	end

  def reader? editor # SHOW
    true
  end

  def updator? editor # EDIT, UPDATE
    return false if !editor
    return true if self.data._id == editor.data._id
    return true if editor.has_power_of?(:ADMIN)
    false
  end

  def self.update id, editor, new_raw_data # UPDATE

    doc = new(id) do
      self.manipulator = editor
      self.raw_data    = new_raw_data
      
      ask_for :add_username 

      if manipulator == self
        ask_for :password  
      end

      if manipulator.has_power_of? ADMIN
        ask_for :security_level
      end
      un_id = nil
      
      save_update :if_valid => lambda {
        if raw_data.add_username
          un_id = __prep_new_username__
        end
      }
      if un_id
        __complete_new_username__ un_id
      end
    end

  end

  def deletor? editor # DELETE
    updator? editor
  end

  # ==== UPDATORS ======================================================
  
  def password_in_reset?
    has_password_reset?
  end
  
  def change_password_through_reset raw_opts 
    if not password_in_reset?
      raise Password_Not_In_Reset, "Can't reset password when account has not been reset."
    end
    
    opts                = Data_Pouch.new(raw_opts, :code, :password, :confirm_password)
    all_values_included = opts.code && opts.password && opts.confirm_password
    raise ArgumentError, "Missing values: #{opts.as_hash.inspect}" if not all_values_included

    if BCrypt::Password.new(password_reset.data.hashed_code) === (opts.code + password_reset.data.salt ) 
      results = Member.update( data._id, self, opts.as_hash ) 
      Password_Resets.delete password_reset.data._id, self
      results
    else
      raise Invalid_Password_Reset_Code, "Member: #{data._id}, Code: #{opts.code}"
    end
  end

  def reset_password 

    code = begin
             # Salt and encrypt values.
             chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
             (1..10).inject('') { |new_pass, i|  
               new_pass += chars[rand(chars.size-1)] 
               new_pass
             }
           end
    salt = begin
             # Salt and encrypt values.
             chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
             (1..10).inject('') { |new_pass, i|  
               new_pass += chars[rand(chars.size-1)] 
               new_pass
             }
           end

    hashed_code = BCrypt::Password.create( code + salt ).to_s
    Password_Resets.create( # Use :save => update OR insert.
													 nil,
													 :_id       => password_reset_id, 
													 :created_at => Couch_Plastic.utc_now, 
													 :owner_id   => data._id,
													 :salt       => salt,
													 :hashed_code => hashed_code
    )
    @password_reset_code = code
  
  end

  # ==== ACCESSORS =====================================================

  def lang
    'en-us'
  end

  # 
  # By using a custom implementation, we cane make sure
  # sensitive information is not shown.
  #
  def inspect
    if new?
      "#<#{self.class}:#{self.object_id} id=[NEW]>"
    else
      "#<#{self.class}:#{self.object_id} id=#{self.data._id}>"
    end
  end

  # Returns: 
  #   Hash
  #     :username_id => username
  #     :username_id => username
  #     :username_id => username
  #
  def username_hash
    @username_hash ||= \
        Life.find(:owner_id=>data._id).inject({}) { |hsh, un| 
          hsh[un['_id']] = un['username']
					hsh
        }
  end
  
  # Returns: 
  #   Array - [ :username ]
  #     
  def usernames
    username_hash.values
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
  def username_menu un_ids = []
    username_hash.map { |id, un|
      { 
        'username_id'   => id,
        'username'      => un,
        'href'      => "/life/#{un}/",
        'selected?'     => un_ids.include?(id),
        'not_selected?' => !un_ids.include?(id)
      }
    }
  end

  # Returns: 
  #   Array - [ :username_id ]
  #
  def username_ids
    username_hash.keys
  end

  def username_to_username_id str
    username_hash.index(str)
  end

  def username_id_to_username raw_id
    id = Couch_Plastic.mongofy_id(raw_id)
    username_hash[id]
  end

  def has_power_of?(raw_level)

    return true if raw_level == self
    
    if raw_level.is_a?(String) || raw_level.is_a?(BSON::ObjectID)
      return true if usernames.include?(raw_level)
      return true if data._id === raw_level
      return true if username_ids.include?(raw_level)
    end

    if !self.class.valid_security_level?(raw_level)
      raise Invalid_Security_Level, raw_level.inspect
    end
    
    target_level = raw_level.to_s
    return false if target_level == NO_ACCESS
    return true if target_level == STRANGER
    return false if new? 

    member_index = SECURITY_LEVELS.index(self.data.security_level)
    target_index = SECURITY_LEVELS.index(target_level)
    return false if not target_index
    return member_index >= target_index

  end # === def security_clearance?

  # 
  # Returns the time passed to it to the Member's local time
  # as a String, formatted i18n to their Country preference.
  # Default value of :utc is Time.now.utc
  # 
  def local_time_as_string( utc = nil )
    utc ||= Time.now.utc
    @tz_proxy ||= TZInfo::Timezone.get(self.timezone)
    @tz_proxy.utc_to_local( utc ).strftime('%a, %b %d, %Y @ %I:%M %p')
  end 

  def current_username_ids
    if current_un_id
      [current_un_id]
    else
      username_ids
    end
  end
  alias_method :life_club_ids, :current_username_ids

  def clubs  un_id, type = nil
    @all_clubs ||= begin
                     Club.hash_for_member(self).values.uniq
                   end
    return @all_clubs if not type
    @all_clubs[type]
  end

  def club_ids 
    (life_club_ids + following_club_ids + owned_club_ids)
  end

  def following_club_ids 
    Club.ids_for_follower_id( :$in => current_username_ids )
  end

  def following_club_id?(club_id)
    club_ids.include?(Couch_Plastic.mongofy_id(club_id))
  end
  
  def owned_club_ids 
    Club.ids_by_owner_id(:$in=>current_username_ids)
  end
  
  def owned_clubs
    Club.by_owner_id(:$in=>current_username_ids)
  end

  def messages_from_my_clubs 
    Message.latest_by_club_id(:$in=>club_ids)
  end

  # Returns:
  #   :as_owner    => { :usernamed_id => [club doc] }
  #   :as_follower => { :usernamed_id => [club doc] }
  #   :as_lifer    => { :usernamed_id => [club doc] }
  #
  def multi_verse
    @multi_verse ||= Club.all_for_member_by_relation(self)
  end
  
  # Accepts:
  #   args - Multiple. Example:
  #     :as_owner
  #     :as_lifer
  #     :as_follower
  #
  # Raises:
  #   ArgumentError - If args has a value not listed above.
  #   
  # Returns:
  #   Hash - {
  #     :username_id => [club doc, club doc]
  #     :username_id => [club doc, club doc]
  #     :username_id => [club doc, club doc]
  #   }
  #
  def multi_verse_per_username_id *args
    valid_types =  [:as_owner, :as_lifer, :as_follower]
    
    types = if args.empty?
              valid_types
            else
              invalid_types = args - valid_types
              raise ArgumentError, "Invalid types: #{invalid_types.inspect}" if not invalid_types
              args
            end
    
    hash = {}
    
    multi_verse.each { |rel, un_id_clubs|
      if types.include?(rel)
        un_id_clubs.each { |un_id, clubs|
          hash[un_id] ||= []
          hash[un_id] += clubs
          hash[un_id] = hash[un_id].uniq
        }
      end
    }
    hash
  end
  
  # Returns:
  #   :username => [Club, Club].uniq
  #   :username => [Club, Club].uniq
  #   :username => [Club, Club].uniq
  #
  def multi_verse_per_username *args
    hash = {}
    multi_verse_per_username_id(*args).each { |k,v|
      hash[username_id_to_username(k)] = v
    }
    hash
  end
  
  # Accepts:
  #   Hash - Optional. {
  #     :username_id => [:club_id, :club_id]
  #     :username_id => [:club_id, :club_id]
  #   }
  #
  # Returns:
  #   Array - [
  #     { 
  #       'username_id'   => id 
  #       'username'      => un 
  #       'clubs'         => {
  #                           :selected?     => Boolean
  #                           :not_selected? => Boolean
  #                         }
  #     }
  #   ]
  #
  def multi_verse_menu selected = {}
    cache_name = selected.empty? ? '{}' : selected.object_id
    multi      = multi_verse_per_username_id( :as_owner, :as_lifer )
    
    multi.map { |un_id, club_arr|
      hash = { 
        'username_id' => un_id,
        'username'    => username_id_to_username(un_id),
        'clubs'       => club_arr.map { |doc|
                          doc['selected?'] = (selected[un_id] || []).include?( doc['_id'] )
                          doc['not_selected?'] = !doc['selected?']
                          doc
                        }
      }
      hash
    }
  end
  
  # Accepts:
  #   Message - Optional.
  #   
  # Returns:
  #   Array - [
  #     {
  #       'username_id'   => id
  #       'username'      => un
  #       'selected?'     => Boolean
  #       'not_selected?' => Boolean
  #     }
  #   ]
  def notifys_menu message = nil
    notifys = message ? 
                message.notifys(self) :
                []
    
    return username_menu if notifys.empty?
    
    username_menu(
      notifys_by_username(mem)
    )
  end
  
  # Accepts:
  #   Message - Optional.
  #   
  # Returns:
  #   Array - [
  #     { 
  #       :username_id   => id 
  #       :username      => un 
  #       :clubs         => [ {
  #                          :selected?     => Boolean
  #                          :not_selected? => Boolean
  #                         } ]
  #     }
  #   ]
  def reposts_menu message = nil
    return multi_verse_menu if not message
    multi_verse_menu(
      message.reposts_by_username(self)
    )
  end

end # === model Member




__END__

  attr_reader :old_un, :old_un_id, :current_un, :current_un_id

  def within_username un, &blok
    within_username_id username_to_username_id(un, &blok)
  end
  
  # This method makes sure username belongs to member.
  # If not, current username/username_id is set to nil.
  def within_username_id un_id
    @old_un_id           = current_un_id
    @old_un              = current_un
    
    @current_un    = username_id_to_username(un_id)
    @current_un_id = username_to_username_id(current_un)
    
    yield
    @current_un    = old_un
    @current_un_id = old_un_id
  end

  make_psuedo :add_username, 
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
  
  def self.by_username raw_username
    username = raw_username.to_s.strip
    doc = find_one_usernames( :username => username )
    if doc && !username.empty?
      Member.by_id(doc['owner_id'])
    else
      raise Not_Found, "Member username: #{username.inspect}"
    end
  end

  def self.by_username_id raw_id
    id = Couch_Plastic.mongofy_id(raw_id)
    doc = find_one_usernames(:_id=>id)
    if doc
      Member.by_id(doc['owner_id'])
    else
      raise Couch_Plastic::Not_Found, "Member Username id: #{raw_id.inspect}"
    end
  end


  def self.failed_attempts_for_today mem, &blok
    require 'time'
    Failed_Log_In_Attempts.find( 
       :owner_id => mem.data._id,  
       :created_at => { :$lte => Couch_Plastic.utc_now,
                 :$gte => Couch_Plastic.utc_string(Time.now.utc - (60*60*24))
       },
       &blok
    ).to_a
  end
