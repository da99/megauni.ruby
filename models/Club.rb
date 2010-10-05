
class Club

  include Couch_Plastic
  
  HREF_PATTERN = [ '/uni/%s/', 'filename' ]

  MEMBERS = %w{ 
    stranger
    member
    insider
    owner
  }.map(&:to_sym)

  INVALID_FILENAMES = %w{ 
    help 
    mega
    mini
    megauni 
    test 
    support 
    admin 
    official 
    indonesia 
    factor 
    happy 
    da01 
    da01tv 
    miniuni 
  }

  enable_created_at

  make :owner_id, :mongo_object_id, [:in_array, lambda { manipulator.username_ids }]
  make :filename, 
       [:stripped, /[^a-zA-Z0-9\_\-\+]/ ], 
       :not_empty,
       [:not_in_array, INVALID_FILENAMES],
       :unique
  make :title, :not_empty
  make :teaser, :not_empty

  
  # ======== Authorizations ======== 

  def self.create editor, raw_raw_data # CREATE
    new do
      
      if editor.usernames.size == 1 || !raw_raw_data['username_id']
        raw_raw_data['owner_id'] ||= editor.username_ids.first
      end
      self.manipulator = editor
      self.raw_data = raw_raw_data
      demand :owner_id, :filename, :title, :teaser
      ask_for_or_default :lang
      save_create 
      
    end
  end

  def self.update id, editor, new_raw_data # UPDATE
    doc = new(id) do
      self.manipulator = editor
      self.raw_data = new_raw_data
      ask_for :title, :teaser
      save_update 
    end
  end

  def allow_to? action, editor
    case action
      
      when :create
        return false if not new?
        return true if editor.has_power_of? :MEMBER
        
      when :read
        true
        
      when :update
        editor.has_power_of?(:ADMIN) ||
          editor.has_power_of?(data.owner_id)
        
      when :delete
        owner? editor
    end
  end

  # ======== Accessors ======== 

  def self.by_filename filename
    find_one(:filename=>filename)
  end

  def self.hash_for_follower mem
    following_ids = []
    clubs         = {}

    hash = Club_Followers.find(
      {:follower_id=>{:$in=>mem.username_ids}}, 
      {:fields=>%w{ follower_id club_id }}
    ).inject({}) { |memo, doc|
      memo[doc['follower_id']] ||= []
      memo[doc['follower_id']] << doc['club_id']
      following_ids << doc['club_id']
      memo
    } 
    
    following = find( :_id => { :$in => following_ids } ).inject({}) { |memo, doc|
      memo[doc['_id']] = doc
      memo
    }
    
    hash.to_a.each { |pair|
      clubs[pair.first] = hash[pair.first].map { |club_id|
        following[club_id]
      } 
    }

    clubs
  end
  
  def self.hash_for_owner mem
    clubs = {}
    find( :owner_id => {:$in=>mem.username_ids} ).each { |doc|
      clubs[doc['owner_id']] ||= []
      clubs[doc['owner_id']] << doc
    }
    clubs
  end

  def self.hash_for_lifer mem
    life_clubs_for_member(mem).inject({}) { |memo, doc| 
      memo[doc.data._id] ||= []
      memo[doc.data._id] << doc.data.as_hash
      memo
    }
  end

  # Returns:
  #   :as_owner    => { :usernamed_id => [Clubs] }
  #   :as_follower => { :usernamed_id => [Clubs] }
  #   :as_lifer    => { :usernamed_id => [Clubs] }
  #
  def self.all_for_member_by_relation mem
    { :as_owner => hash_for_owner(mem), :as_follower => hash_for_follower(mem), :as_lifer  => hash_for_lifer(mem)}
  end

  def self.all_ids_for_owner( raw_id )
    id = Couch_Plastic.mongofy_id( raw_id )
    find({:owner_id=>id}, {:fields=>'_id'}).map { |doc|
      doc['_id']
    }
  end

  def self.ids_for_follower_id( raw_id )
    id = Couch_Plastic.mongofy_id( raw_id )
    following = find_followers({:follower_id=>id}, {:fields=>'club_id'}).map { |doc|
      doc['club_id']
    } 
    owned = all_ids_for_owner(raw_id)
    (following + owned).uniq
  end

  def self.all_filenames 
    find(
      { :owner_id => {:$in=>Member.by_filename('da01tv').username_ids} },
      { :fields => 'filename' }
    ).map {|r| r['filename']}
  end

  def self.by_club_model raw_models, opts = {}
    models = [raw_models].flatten.compact.uniq
    clubs = find({:club_model=>{:$in=>models}}, opts)
  end

  def self.ids_by_owner_id raw_id, raw_opts = {}
    id   = Couch_Plastic.mongofy_id(raw_id)
    opts = {:fields => '_id'}.update(raw_opts)
    find({:owner_id => id }, opts).map { |doc|
      doc['_id']
    }
  end

  def self.by_owner_ids raw_id, raw_opts={}
    id = Couch_Plastic.mongofy_id(raw_id)
    find(
      {:owner_id=>id},
      raw_opts
    )
  end

  def owner?(mem)
    return false if not mem
    mem.username_ids.include?(data.owner_id)
  end

  %w{ e magazine news qa shop random thanks fights delete_follow members }.each do |suffix|
    eval %~
      def href_#{suffix}
        File.join(href, '#{suffix}/')
      end
    ~
  end

  def href_follow
    File.join(href, "/follow/")
  end

  def followers
    (find_followers(:club_id=>data._id).map { |doc|
      doc['follower_id']
    } + [data.owner_id])
  end

  def potential_follower? mem
    !follower?(mem)
  end

  def follower? mem
    mem.following_club_id?(data._id)
  end

end # === Club

__END__

