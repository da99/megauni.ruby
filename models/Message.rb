
class Message

  DECLINE = -1
  PENDING = 0
  ACCEPT  = 1

  module SECTIONS
    E      = 'Encyclopedia'
    R      = 'Random'
    F      = 'Fights'
    PREDICTIONS = 'Predictions'
    RANDOM = 'RANDOM'
    MAG    = 'Magazine'
    NEWS   = 'News'
    QA     = 'Q & A'
    SHOP   = 'Shop'
    FIGHTS = 'Fights'
    THANKS = 'Thanks'
  end

  MODEL_HASH = {
    'news' => ['important news', SECTIONS::NEWS],
    'comment' => ['comment'],
    'random' => ['random info.', SECTIONS::R],
    'fight' => ['fight', SECTIONS::F],
    'debate' => ['friendly debate', SECTIONS::F],
    'complaint' => ['complaint', SECTIONS::F],
    'prediction' => ['prediction', SECTIONS::PREDICTIONS],
    'mag_story'  => ['magazine article', SECTIONS::MAG],
    'question'   => ['question', SECTIONS::QA],
    'cheer'      => ['cheer reply', SECTIONS::THANKS],
    'jeer'      => ['critique reply', SECTIONS::THANKS],
    'suggest'      => ['suggestion', SECTIONS::THANKS],
    'e_chapter' => ['encyclopedia chapter', SECTIONS::E],
    'e_quote' => ['quotation', SECTIONS::E],
    'buy'     => ['buy it', SECTIONS::SHOP],
    'thank'   => ['thanks', SECTIONS::THANKS],
    'repost'  => ['repost', 'everywhere']
    # plea  
    # fulfill
    # event
  }
  
  MODELS = MODEL_HASH.keys
  
  include Couch_Plastic

  enable_timestamps
  
  make_psuedo :editor_id, :mongo_object_id, [:in_array, lambda { manipulator.lifes._ids } ]

  make :message_model, [:in_array, MODELS]
  make :important, :not_empty
  make :rating, :not_empty
  make :privacy, [:in_array, ['private', 'public', 'friends_only'] ]
  make :owner_id, :mongo_object_id, [:in_array, lambda { manipulator.lifes._ids } ]
  make :parent_message_id, :mongo_object_id, [:set_raw_data, [:target_ids, lambda { 
    mess = Message.by_id(raw_data.parent_message_id)
    mess.data.target_ids
  }]]
  make :target_ids    , :split_and_flatten, :mongo_object_id_array
  make :emotion       , :not_empty
  make :category      , :not_empty
  make :labels        , :split_and_flatten, :array
  make :public_labels , :split_and_flatten, :array
  make :private_labels, :split_and_flatten, :array
  make :title         , :anything
  make :answer        , :anything
  make :teaser        , :anything
  make :published_at  , :datetime_or_now
  make :body          , :not_empty
  make :owner_accept, :require_owner_as_manipulator, :integer, [ :in_array, [DECLINE, PENDING, ACCEPT]]
  make :body_images_cache, [:set_to, lambda { 
    # turn "URL 100 100" into 
    # ==> [URL, 100, 100]
    # ==> BSON won't allow URL as key because it contains '.'
    raw_data.body_images_cache.to_s.split("\n").map { |val|
      url, width, height = val.split.map(&:strip)
      [url, width.to_i, height.to_i]
    }
  }]

  # ==== Associations   ====

  has_many :notifys, Member_Notifys
  has_many :reposts, Member_Reposts


  # ==== Authorizations ====
 
  def allow_as_creator? editor # NEW, CREATE
    return false unless editor
    editor.has_power_of? :MEMBER
  end

  def self.create editor, raw_data
    d = new do
      self.manipulator = editor
      self.raw_data = raw_data
      new_data.labels = []
      new_data.public_labels = []
      ask_for_or_default :lang
      ask_for :parent_message_id
      demand :owner_id, :target_ids, :body, :message_model
      ask_for :title, :category, :privacy, :labels,
          :emotion, :rating,
          :labels, :public_labels,
          :important,
          :body_images_cache
      save_create 
    end
  end

  def reader? editor # SHOW
    true
  end

  def updator? editor # EDIT, UPDATE
    owner? editor
  end

  def self.update id, editor, new_raw_data
    doc = new(id) do
      self.manipulator = editor
      self.raw_data    = new_raw_data
      ask_for :title, :body, :teaser, :public_labels, 
        :private_labels, :published_at,
        :message_model, :important,
        :body_images_cache,
        :editor_id,
        :owner_accept
      save_update :record_diff => true
    end
  end

  def deletor? editor # DELETE
    true
  end

  # ==== Accessors ====

  def self.message_model?( str_or_hash )
    case str_or_hash
    when String
      MODELS.include?(str_or_hash)
    when Hash
      !!(str_or_hash.values.flatten.detect { |mod| MODELS.include?(mod) })
    else
      raise ArgumentError, "Unknown type: #{str_or_hash}"
    end
  end

  def self.find_with_selector_validation selector, params = {}, &blok
    mess_model = selector[:message_model] || selector['message_model']
    if mess_model
      valid    = message_model?(mess_model)
      raise "Invalid message model #{mess_model.inspect}" if not valid
    end
    Member.relationize(
      find_wo_validation(selector, params, &blok)
    )
  end
  
  class << self
    alias_method :find_wo_validation, :find
    alias_method :find, :find_with_selector_validation
  end

  def self.latest_by_club_id club_id, raw_params = {}, raw_opts = {}, &blok
    params = {:target_ids =>club_id, :parent_message_id => nil, :privacy => 'public' }.update(raw_params)
    opts   = {:limit=>10, :sort=>[:_id, :desc]}.update(raw_opts)
    find(
      params,
      opts,
      &blok
    )
  end

  def self.latest_comments_by_club_id club_id, raw_params = {}, *args
    params = {:message_model => {:$in=>%w{jeer cheer}}}.update(raw_params)
    Message.latest_by_club_id(club_id, params, *args)
  end

  def self.latest_questions_by_club_id club_id, raw_params = {}, *args
    params = {:message_model => 'question'}.update(raw_params)
    Message.latest_by_club_id(club_id, params, *args)
  end

  def self.latest_by_parent_message_id mess_id, raw_params = {}, raw_opts = {}, &blok
    params = {:parent_message_id =>mess_id, :privacy => 'public' }.update(raw_params)
    opts   = {:limit=>10, :sort=>[:_id, :desc]}.update(raw_opts)
    find(
      params,
      opts,
      &blok
    )
  end
  
  def self.latest_comments_by_parent_message_id mess_id, raw_params = {}, *args
    params = {:message_model => {:$in=>%w{jeer cheer}}}.update(raw_params)
    Message.latest_by_parent_message_id(mess_id, params, *args)
  end

  def self.latest_questions_by_parent_message_id mess_id, raw_params = {}, *args
    params = {:message_model => 'question'}.update(raw_params)
    Message.latest_by_parent_message_id(mess_id, params, *args)
  end

  def self.public raw_params = {}, raw_opts = {}, &blok
    opts = {:limit=>10, :sort=>[:_id, :desc]}.update(raw_opts)
    include_mods = [opts.delete(:include)].flatten.compact
    params = {}.update(raw_params)
    cursor = find(
      params, 
      opts,
      &blok
    )
    if include_mods.empty?
      cursor
    else
      docs = cursor
      if include_mods.include?(Member)
        docs = Couch_Plastic.relationize(docs, Life, 'owner_id', 'username' => 'owner_username')
      end
      if include_mods.include?(Club)
        docs = Couch_Plastic.relationize(docs, Club, 'target_ids', 'title'=>'club_title', 'filename' => 'club_filename')
      end
      docs
    end
  end

  def self.public_labels target_ids = nil
    map = %~
      function () {
          for (var i in this.tags) {
              emit(this.tags[i], {total:1});
          }
      };
    ~
    reduce = %~
      function (key, value) {
          var sum = 0;
          value.forEach(function (doc) {sum += doc.total;});
          return {total:sum};
      };
    ~
    opts = if target_ids
             { :query => { :target_ids=> { :$in=>target_ids}} }
           else
             { :query => { :tags => { :$ne => nil } } }
           end
    
    db_collection.map_reduce(map, reduce, opts).find().map { |doc| doc['_id'] }
  end

  def self.by_public_label label, raw_params={}, &blok
    params = { :public_labels => {:$in=>[label]} }.update(raw_params)
    find( params, &blok )
  end

  def self.by_club_id_and_public_label club_id, label, raw_params = {}, raw_opts={}, &blok
    params = { 
              :target_ids    => {:$in=>[club_id]},
              :public_labels => {:$in=>[label].flatten}
              }.update(raw_params)
    opts = {:sort=>[:_id, :desc]}.update(raw_opts)
    find(params, &blok)
  end

  def self.by_published_at *args, &blok
    if args.size === 1
      raw_opts=args.first
      opts = {}.update(raw_opts)
      params = {}
    else
      case args.size
      when 2
        start_year = args[0].to_i
        start_month = args[1].to_i
        case start_month
        when 12
          end_month = 1
          end_year = (start_year + 1)
        else
          end_month = start_month + 1
          end_year = start_year
        end
      when 4
        start_year, start_month, end_year, end_month = args
      else
        raise ArgumentError, "Unknown argument list: #{args.inspect}"
      end
      time_format = '%Y-%m-%d %H:%M:%S'
      start_tm = Time.utc(start_year, start_month).strftime(time_format)
      end_tm   = Time.utc(end_year, end_month).strftime(time_format)
      params = {:published_at=>{'$gt'=>start_tm,'$lt'=>end_tm}}
      opts = {}
    end
    # time_format = '%Y-%m-%d %H:%M:%S'
    # dt = Time.now.utc
    # start_dt = dt.strftime(time_format)
    # end_dt   = (dt + (60 * 60 * 24)).strftime(time_format)
    find(params, opts, &blok )
  end

  def self.by_club_id_and_published_at club_id, raw_params = {}, opts = {}, &blok
    find(
      {:target_ids=>Club.filename_to_id(club_id)},
      opts, 
      &blok
    )
  end
  

  def self.by_old_id id
    old_id = "message-#{id}"
    mess = find_one(:old_id=>old_id)
    if mess
      by_id(mess['_id'])
    else
      by_id(old_id)
    end
  end

  # ==== Accessors =====================================================

  # Accepts:
  #    Member - Required.
  #
  #  Returns:
  #    Array - [
  #      {
  #        'owner_id'   => id
  #        'message_id' => id
  #        '_id'        => id
  #      }
  #    ]
  def notifys mem 
    update_association :notifys, \
      Member_Notifys.find( 
                          :message_id => data._id,
                          :owner_id   => { :$in=>mem.lifes._ids } 
                         ).to_a
  end

  # Accepts:
  #    Member - Required.
  #
  #  Returns:
  #    Array - [
  #      {
  #        'message_model' => 'repost'
  #        'owner_id'   => id
  #        'target_ids' => []
  #        'message_id' => id
  #        '_id'        => id
  #      }
  #    ]
  def reposts mem
    update_association :reposts, \
      Member_Reposts.find( 
                          :message_id => data._id,
                          :owner_id   => { :$in=>mem.lifes._ids },
                          :message_model => 'repost'
                         ).to_a
  end

  def product?
    data.public_labels && data.public_labels.include?('product')
  end

  def published_at
    Time.parse(data.published_at || data.created_at)
  end

  def last_modified_at
    latest = [data.created_at, data.updated_at, data.published_at].compact.sort.first
    Time.parse(latest)
  end

  def clubs
    @clubs ||= data.target_ids.map { |id|
      begin
        Club.by_id_or_member_username_id(id)
      rescue Club::Not_Found
        nil
      end
    }.compact
  end

  def href
    "/mess/#{data._id}/"
  end

  def href_notify
    File.join(href, 'notify/')
  end

  def href_repost
    File.join(href, 'repost/')
  end

  def href_edit
    File.join(href, 'edit/')
  end

  def href_log
    File.join(href, 'log/')
  end
  
  def href_parent
    "/mess/#{data.parent_message_id}/"
  end

  def href_club
    clubs.first.href
  end

  def href_section
    suffix = case message_section
      when Message::SECTIONS::E
        'e'
      when Message::SECTIONS::QA
        'qa'
      else
        message_section.to_s.downcase.split.join('_')
      end
    File.join(href_club, suffix + '/')
  end
  
  def message_model_in_english
    if data.message_model
      Message::MODEL_HASH[data.message_model].first 
    else
      'unkown'
    end
  end

  def message_section
    if data.message_model
      Message::MODEL_HASH[data.message_model][1]
    else
      'Unknown'
    end
  end
  
  def responds
      Message.latest_by_parent_message_id(self.data._id).to_a 
  end

  def critiques
    select_responds_by_model('cheer', 'jeer')
  end
  
  def suggests
    select_responds_by_model('suggest')
  end
  
  def questions
    select_responds_by_model('question')
  end

  private 
  
  def select_responds_by_model(*mods)
    responds.select { |doc|
      mods.include?(doc['message_model'])
    }
  end


end # === end Message
