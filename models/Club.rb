
class Club

  include Mongo_Dsl
  
  HREF_NAMESPACE = '/uni'
  HREF_PATTERN   = [ '/uni/%s/', 'filename' ]
  HREF_SUFFIXES  = %w{ follow e magazine news qa shop random thanks fights delete_follow members }

  MEMBERS = %w{ 
    stranger
    member
    insider
    owner
  }.map(&:to_sym)

  INVALID_FILENAMES = File.read('models/INVALID_FILENAMES.txt') \
                        .split
                        .map(&:strip)
                        .map { |str|
                          [str, str + 's']
                        }.flatten

  # ======== Fields ======== 
    
  enable_created_at

  make :owner_id, :mongo_object_id, [:in_array, lambda { manipulator.lifes._ids }]
  make :filename, 
       [:stripped, /[^a-zA-Z0-9\_\-\+]/ ], 
       :not_empty,
       [:not_in_array, INVALID_FILENAMES],
       :unique
  make :title, :not_empty
  make :teaser, :not_empty

  # ======== Associations   ======== 
  
  has_many :messages, Message, :target_ids do
    where :parent_message_id => nil
    where :privacy => 'public'
    limit 10
    sort  [:_id, :desc]
    
    find_by_date :published_at
  end

  has_many :comments do
    based_on :messages
    where_in :message_model, %w{ jeer cheer }
  end

  has_many :questions do
    based_on :messages
    where    :message_model => 'question'
  end

  # ======== Authorizations ======== 

  class << self
    
    def create editor, raw_raw_data # CREATE
      new do
        
        if editor.lifes.usernames.size == 1 || !raw_raw_data['username_id']
          raw_raw_data['owner_id'] ||= editor.lifes._ids.first
        end
        self.manipulator = editor
        self.raw_data = raw_raw_data
        demand :owner_id, :filename, :title, :teaser
        ask_for_or_default :lang
        save_create 
        
      end
    end

    def update id, editor, new_raw_data # UPDATE
      doc = new(id) do
        self.manipulator = editor
        self.raw_data = new_raw_data
        ask_for :title, :teaser
        save_update 
      end
    end
    
  end # == self

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

  # ======== Class Methods ======== 
  
  class << self 
    
    def relationize docs, namespace = 'club'
      Mongo_Dsl.relationize(
        doc,
        self,
        'target_ids', 
        'title'    => "#{namespace}_title",
        'filename' => "#{namespace}_filename"
      )
    end
    
  end # === self

  # ======== Accessors ======== 

  class << self 

    # member.lifes.clubs.follows.group_by(:follower_id).map( Club ).go!
    #   => Grab all Club_Follow for member, with only fields :follower_id, :club_id
    #      and then convert each :club_id to Club docs.
    # 
    # Returns:
    #   { 
    #     :follower_id => [ club, club ],
    #     :follower_id => [ club, club, club ]
    #   }
    #   
    def hash_for_follower mem
      raise "No longer allowed"
    end
    
    # member.lifes.clubs.owned.group_by(:owner_id).go!
    #
    # Returns:
    #   { 
    #     :owner_id => [ club, club ],
    #     :owner_id => [ club ]
    #   }
    def hash_for_owner mem
      raise "No longer allowed"
    end

    # member.lifes.group_by(:life_id).map(Club).go!
    # 
    # Returns:
    #   {
    #     :username_id => [ life, life ]
    #     :username_id => [ life ]
    #   }
    def hash_for_lifer mem
      raise "No longer allowed"
    end

    # Returns:
    #   :as_owner    => { :usernamed_id => [Clubs] }
    #   :as_follower => { :usernamed_id => [Clubs] }
    #   :as_lifer    => { :usernamed_id => [Clubs] }
    #
    def all_for_member_by_relation mem
      { :as_owner => hash_for_owner(mem), :as_follower => hash_for_follower(mem), :as_lifer  => hash_for_lifer(mem)}
    end

    # member.lifes.clubs._ids.go!
    #   => Grabs only field, :_id, and maps each doc as: doc['_id']
    #   
    # Returns:
    #   [ club_id, club_id, club_id ]
    #   
    def all_ids_for_owner( raw_id )
      id = Mongo_Dsl.mongofy_id( raw_id )
      find({:owner_id=>id}, {:fields=>'_id'}).map { |doc|
        doc['_id']
      }
    end

    # member.life.first.club_follows.map(:club_id).go!
    #
    # Returns:
    #   [ club_id, club_id, club_id ]
    #
    def ids_for_follower_id( raw_id )
      id = Mongo_Dsl.mongofy_id( raw_id )
      following = find_followers({:follower_id=>id}, {:fields=>'club_id'}).map { |doc|
        doc['club_id']
      } 
      owned = all_ids_for_owner(raw_id)
      (following + owned).uniq
    end

    # da01tv.lifes.clubs.map(:filename).go!
    # 
    # Returns: 
    #   [ club_filename, club_filename, club_filename ]
    def all_filenames 
    end

    # Club.all.where_in(:club_model, models ).go!
    # 
    # Returns:
    #   [ doc, doc, doc ]
    def by_club_model raw_models, opts = {}
    end

    # member.life.first.clubs.map(:_id).go!
    # 
    # Returns:
    #   [ club_id, club_id, club_id ]
    #   
    def ids_by_owner_id raw_id, raw_opts = {}
      id   = Mongo_Dsl.mongofy_id(raw_id)
      opts = {:fields => '_id'}.update(raw_opts)
      find({:owner_id => id }, opts).map { |doc|
        doc['_id']
      }
    end

    # member.life.clubs.go!
    #
    # Returns:
    #   [ doc, doc, doc ]
    #   
    def by_owner_ids raw_id, raw_opts={}
    end
    
  end # === self

  def owner?(mem)
    return false if not mem
    mem.lifes._ids.include?(data.owner_id)
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

  module Results
    
    def href
      first.href
    end

  end # === module

end # === Club

__END__

