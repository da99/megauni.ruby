

class Password_Resets

  include Couch_Plastic

  attr_reader :code

  # ==== CONSTANTS ====
  
  In_Reset       = Class.new( StandardError )
  Not_In_Reset   = Class.new( StandardError )
  Invalid_Code   = Class.new( StandardError )
  
  # ==== Fields  ====
  
  enable_timestamps
  make :owner_id, :mongo_object_id
  make :salt, :anything
  make :hashed_code, :anything

  # ==== Associations  ====
    
  belongs_to :owner, Member

  # ==== Class Methods ====
  
  class << self

    def create member

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
      
      new do
        self.manipulator = member
        self.raw_data = {
          :owner_id    => data._id,
          :salt        => salt,
          :hashed_code => hashed_code
        }

        demand :owner_id, :salt, :hashed_code
        set_id( member.data._id )
        save_upsert
        
        @code = code
      end
    
    end
  
  end # === self
  # ==== Authorizations ====
 
  def allow_to? action, editor
    case action
    when :create
      true
    when :read
      false
    when :update
      false
    when :delete
      false
    end
  end

  # ==== Accessors ====
  
  def change_password raw_opts 
    
    if new?
      raise Not_In_Reset, "Can't reset password when account has not been reset."
    end
    
    opts                = Data_Pouch.new(raw_opts, :code, :password, :confirm_password)
    all_values_included = opts.code && opts.password && opts.confirm_password
    raise ArgumentError, "Missing values: #{opts.as_hash.inspect}" if not all_values_included

    if BCrypt::Password.new(password_reset.data.hashed_code) === (opts.code + password_reset.data.salt ) 
      results = Member.update( data._id, self, opts.as_hash ) 
      Password_Resets.delete password_reset.data._id, self
      results
    else
      raise Invalid_Code, "Member: #{data._id}, Code: #{opts.code}"
    end
    
  end


end # === end Password_Resets
