
class Club

  include Couch_Plastic
  
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

  attr_reader :life, :life_username, :life_member
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

  def allow_as_creator? editor 
    return false if not new?
    return true if editor.has_power_of? :MEMBER
    # editor.has_power_of? Member::ADMIN
  end

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

  def reader? editor
    true
  end

  def updator? editor
    return false if not editor
    return false if not data.owner_id
    editor.has_power_of?(:ADMIN) ||
      editor.has_power_of?(data.owner_id)
  end

  def self.update id, editor, new_raw_data # UPDATE
    doc = new(id) do
      self.manipulator = editor
      self.raw_data = new_raw_data
      ask_for :title, :teaser
      save_update 
    end
  end
  
  def deletor? editor
    owner? editor
  end

  # ======== Accessors ======== 

  def self.by_filename filename
    doc = find_one(:filename=>filename)
    return Club.new(doc) if doc
    raise Club::Not_Found, "Filename: #{filename}"
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
  
  def set_as_life username, mem
    @life_club     = true
    @life_username = username
    @life_member   = mem
  end

  def self.life_clubs_for_member mem
    mem.usernames.map { |filename|
      life_club_for_username(filename, mem)
    }
  end

  def self.life_club_for_username filename, mem
    doc = mem.data.as_hash.clone
    doc['filename']  = filename
    doc['title']     = "The Universe of #{filename}"
    doc['_id']       = mem.username_to_username_id(filename)
    doc['owner_id']  = doc['_id']
    club = Club.new doc
    club.set_as_life filename, mem
    club
  end

  def self.by_filename_or_member_username filename
    begin
      by_filename filename
    rescue Club::Not_Found
      begin
        mem = Member.by_username(filename)
        life_club_for_username(filename, mem)
      rescue Member::Not_Found
        raise Club::Not_Found, "Filename: #{filename.inspect}"
      end
    end
  end

  def self.by_id_or_member_username_id id
    begin
      by_id(id)
    rescue Club::Not_Found
      begin
        mem = Member.by_username_id(id)
        by_filename_or_member_username( mem.username_id_to_username(id) )
      rescue Member::Not_Found, Club::Not_Found
        raise Club::Not_Found, "ID: #{id.inspect}"
      end
    end
  end

  def self.all raw_params = {}, &blok
    find( raw_params, &blok)
  end

  def self.all_ids params = {}, opts = {}
    find( params, {:fields=>['_id']}.update(opts) ).map { |doc|
      doc['_id']
    }
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

  def self.add_clubs_to_collection raw_coll
    coll     = (raw_coll.is_a?(Array)) ? raw_coll : raw_coll.to_a
    club_ids = coll.map { |doc| doc['target_ids'] }.compact.flatten.uniq
    clubs    = find({ :_id=>{:$in=>club_ids}}).inject({}) { | m, club| 
      m[club['_id']] = club
      m
    } 
    
    coll.map { |doc|
      target = clubs[doc['target_ids'].first]
      doc['club_title'], doc['club_filename'] = if target
                                                  [target['title'], target['filename']]
                                                end

      doc
    }
  end

  def self.by_club_model raw_models, opts = {}
    models = [raw_models].flatten.compact.uniq
    clubs = find({:club_model=>{:$in=>models}}, opts)
  end
  
  def self.by_filename filename
    club = find_one('filename'=>filename)
    if not club
      raise Couch_Plastic::Not_Found, "Club by filename: #{filename.inspect}"
    end
    Club.new(club)
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

  def life_club?
    !!@life_club
  end
  alias_method :life?, :life_club?

  def href 
    "/uni/#{data.filename}/"
  end
  alias_method :href_delete, :href

  %w{ e magazine news qa shop random thanks fights delete_follow members }.each do |suffix|
    eval %~
      def href_#{suffix}
        File.join(href, '#{suffix}/')
      end
    ~
  end

  def href_edit
    File.join(href, 'edit/' )
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

  # === Other Instance Methods

  def create_follower mem, username_id
    self.class.db_collection_followers.insert(
      '_id' => "#{data._id}#{mem.data._id}",
      'club_id' => data._id, 
      'follower_id' => Couch_Plastic.mongofy_id(username_id)
    )
  end

end # === Club
