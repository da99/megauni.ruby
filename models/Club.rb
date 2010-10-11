
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
  
  has_many :messages do
    where_in :target_ids
    where :parent_message_id => nil
    where :privacy => 'public'
    limit 10
    sort  [:_id, :desc]
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
      (super).instance_eval do
        demand :owner_id, :filename, :title, :teaser
        ask_for_or_default :lang
        save_create 
      end
    end

    def update id, editor, new_raw_data # UPDATE
      (super).instance_eval do
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
  
  # class << self 
  # end # === self

  # ======== Accessors ======== 

  class << self 

    # Returns:
    #   :as_owner    => { :usernamed_id => [Clubs] }
    #   :as_follower => { :usernamed_id => [Clubs] }
    #   :as_lifer    => { :usernamed_id => [Clubs] }
    #
    def all_for_member_by_relation mem
      { :as_owner => mem.club_owner_menu, 
        :as_follower => mem.club_follower_menu, 
        :as_lifer  => mem.life_menu}
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
      owned = Member.find._id(raw_id).go!.club_owner_ids
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

    
    def relationize docs, namespace = 'club'
      Mongo_Dsl.relationize(
        doc,
        self,
        'target_ids', 
        'title'    => "#{namespace}_title",
        'filename' => "#{namespace}_filename"
      )
    end
    
