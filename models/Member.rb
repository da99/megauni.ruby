require 'bcrypt'

class Member 

  include Couch_Plastic

  def self.db_collection
    @coll ||= DB.collection('Members')
  end

      
  # =========================================================
  #                     CONSTANTS
  # =========================================================  
  
  Wrong_Password         = Class.new( StandardError )
  Password_Reset         = Class.new( StandardError )
  Invalid_Security_Level = Class.new( StandardError )

  SECURITY_LEVELS        = %w{ NO_ACCESS STRANGER  MEMBER  EDITOR   ADMIN }
  SECURITY_LEVELS.each do |k|
    const_set k, k
  end
  
  EMAIL_FINDER        = /[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]/
  VALID_EMAIL_FORMAT  = /\A#{EMAIL_FINDER}\z/

  #VALID_USERNAME_FORMAT = /\A[a-zA-Z0-9\-\_\.]{2,25}\z/
  #VALID_USERNAME_FORMAT_IN_WORDS = "letters, numbers, underscores, dashes and periods."

  enable_timestamps
  
  %w{ 
      update_username
      confirm_password 
  }.each { |fld|
    make_psuedo fld, :not_empty
  }

  [ 
    :hashed_password, 
    :salt
  ].each { |f| make f, :not_empty}
               
  make :security_level, [:in_array, SECURITY_LEVELS]
  
  make :email, 
    :string,
    [:stripped, /[^a-z0-9\.\-\_\+\@]/i ],
    [:match, /\A[a-zA-Z0-9\.\-\_\+]{1,}@[a-zA-Z0-9\-\_]{1,}[\.]{1}[a-zA-Z0-9\.\-\_]{1,}[a-zA-Z0-9]\Z/ ],
    [:min, 6],
    [:equal, lambda { raw_data[:email] } ],
    [:error_msg, 'Email has invalid characters.']

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

  def self.valid_security_level?(perm_level)
    return true if SECURITY_LEVELS.include?(perm_level)
    case perm_level
    when Mongo::ObjectID, Member, String, Symbol
      true
    else
      false
    end
  end
  
  def self.db_collection_usernames
    @coll_usernames ||= DB.collection('Member_Usernames')
  end

  def self.db_collection_failed_attempts
    @coll_failed_attempts ||= DB.collection('Member_Failed_Attempts')
  end

  def self.db_collection_password_resets
    @coll_password_resets ||= DB.collection('Member_Password_Resets')
  end

  # ==== Getters =====================================================    
  
  def self.by_username raw_username
    username = raw_username.to_s.strip
    doc = db_collection_usernames.find_one( :username => username )
    if doc && !username.empty?
      Member.by_id(doc['owner_id'])
    else
      raise Couch_Plastic::Not_Found, "Member Username: #{username.inspect}"
    end
  end

  def self.failed_attempts_for_today mem, &blok
    require 'time'
    db_collection_failed_attempts.find( 
       :owner_id => mem.data._id,  
       :created_at => { :$lte => Couch_Plastic.utc_now,
                 :$gte => Couch_Plastic.utc_string(Time.now.utc - (60*60*24))
       },
       &blok
    ).to_a
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

    mem = Member.by_username( username )

    # Check for Password_Reset
    pass_reset_id = "#{mem.data._id}-password-reset"
    if db_collection_password_resets.find_one(:_id=>pass_reset_id)
      raise Password_Reset, mem.inspect
    end

    # See if password matches with correct password.
    correct_password = BCrypt::Password.new(mem.data.hashed_password) === (password + mem.data.salt)
    return mem if correct_password

    # Grab failed attempt count.
    fail_count = Member.failed_attempts_for_today(mem).count
    new_count  = fail_count + 1
    
    # Insert failed password.
    db_collection_failed_attempts.insert(
      { :data_model => 'Member_Failed_Attempt',
      :owner_id   => mem.data._id, 
      :date       => Couch_Plastic.utc_date_now, 
      :time       => Couch_Plastic.utc_time_now,
      :created_at => Couch_Plastic.utc_now,
      :ip_address => ip_addr,
      :user_agent => user_agent },
      :safe => false
    )

    # Raise Account::Reset if necessary.
    if new_count > 2
      db_collection_password_resets.insert(
        {:_id=>pass_reset_id, 
        :created_at=>Couch_Plastic.utc_now, 
        :owner_id=>mem.data._id},
        :safe=>false
      )
      raise Password_Reset, mem.inspect
    end

    raise Wrong_Password, "Password is invalid for: #{username.inspect}"
  end 

  # ==== Authorizations ====

  def creator? editor # NEW, CREATE
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
      un_id = nil
      save_create :if_valid => lambda { 
        un_id = __prep_new_username__
      }
      __complete_new_username__ un_id
    end
  end

  def __prep_new_username__
    add_unique_key 'username', "Username, #{clean_data.add_username}, already taken."
    self.class.db_collection_usernames.insert(
      { :username   => clean_data.add_username,  
        :owner_id   => nil}, 
        :safe=>true
    )
  end

  def __complete_new_username__ un_id
    self.class.db_collection_usernames.update(
      {'_id'=>un_id}, 
      {:username=>clean_data.add_username, :owner_id=>data._id}, 
      :safe=>true
    )
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
  
  def usernames
    cache[:usernames] ||= username_hash.values
  end

  def username_ids
    cache[:username_ids] ||= username_hash.keys
  end

  def username_hash
    cache[:username_hash] = begin
                                    hsh = {}
                                    self.class.db_collection_usernames.find(:owner_id=>data._id).map { |un| 
                                      hsh[un['_id']] = un['username']
                                    }
                                    hsh
                                  end
  end

  def username_to_username_id str
    username_hash.index(str)
  end

  def has_power_of?(raw_level)

    return true if raw_level == self
    
    if raw_level.is_a?(String) || raw_level.is_a?(Mongo::ObjectID)
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
  
  def potential_clubs
    cache[:potential_clubs] ||= begin
                                  Club.all(:_id=>{:$in => potential_club_ids})
                                end
  end

  def potential_club_ids
    cache[:potential_club_ids] ||= begin
                                  created   = Club.all_ids_for_owner( self.data._id )
                                  Club.all_ids(:_id=>{:$nin => created+following_club_ids})
                                end
  end

  def following_club_ids un_id = nil
    if un_id
      cache["follwing_club_ids_#{un_id}"] ||= Club.all_ids_for_follower_id(un_id)
    else
      cache[:following_club_ids] ||= Club.all_ids_for_follower(self.data._id)
    end
  end

  def newspaper username = nil
    if username
      cache["newspaper_#{username}"] ||= begin
                                            un_id = username_to_username_id(username)
                                            raise "Username does not belong to user: #{username.inspect}" unless un_id
                                            club_ids = following_club_ids(un_id)
                                            Message.db_collection.find( {:target_ids=>{:$in=>club_ids}}, { :limit => 10 })
                                          end
    else
      cache[:newspaper] ||= Message.db_collection.find( {:target_ids=>{:$in=>following_club_ids}}, {:limit=>10})
    end
  end

  def clubs
    []
  end
  
end # === model Member




