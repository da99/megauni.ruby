

class Club_Followers

  include Couch_Plastic

  enable_timestamps
  
  make :_id, [:set_to, lambda { "#{new_data.club_id}-#{new_data.follower_id}" }]
  make :club_id, :mongo_object_id
  make :follower_id, :mongo_object_id
  
  # ==== Associations   ====
  belongs_to :club

  # ==== Authorizations ====
 
  def allow_to? action, editor # NEW, CREATE
    case action
    when :create
      true
    when :read
      true
    when :update
      true
    when :delete
      true
    end
  end

  class << self

    def create editor, raw_raw_data
      new do
        self.manipulator = editor
        self.raw_data = raw_raw_data
        demand :_id, :club_id, :follower_id
        save_create
      end
    end

  end # == self

  # ==== Accessors ====

  

end # === end Club_Followers


__END__

  # === Other Instance Methods

  def create_follower mem, username_id
    Club_Followers.create(
      mem,
      '_id' => "#{data._id}#{mem.data._id}",
      'club_id' => data._id, 
      'follower_id' => Couch_Plastic.mongofy_id(username_id)
    )
  end


