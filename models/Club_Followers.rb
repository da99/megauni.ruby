

class Club_Followers

  include Couch_Plastic

  enable_timestamps
  
  make :club_id, :mongo_object_id
  make :follower_id, :mongo_object_id

  # ==== Authorizations ====
 
  def allow_to? action, editor # NEW, CREATE
    case action
    when :create
      when :read
    when :update
    when :delete
    end
  end

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


