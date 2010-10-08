require 'mongo'
require 'loofah'
require 'models/Data_Pouch'

DB_CONN = if The_App.production?
            DB_NAME          = "mu02"
            DB_HOST          = "pearl.mongohq.com:27027/#{DB_NAME}"
            DB_USER          = 'da01'
            DB_PASSWORD      = "isle569vxwo103"
            DB_CONN_STRING   = "#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}"
            MONGODB_CONN_STRING ="mongodb://#{DB_CONN_STRING}"
            DB_SESSION_TABLE = 'rack_sessions'
            Mongo::Connection.from_uri(
              MONGODB_CONN_STRING,
              :timeout=>3
            ) 
          else
            case The_App.environment
            when 'development'
              DB_NAME = "megauni_dev"
            when 'test'
              DB_NAME = "megauni_test"
            end
            DB_HOST          = "localhost:27017/#{DB_NAME}"
            DB_USER          = 'da01'
            DB_PASSWORD      = "kgflw30zeno4vr"
            DB_CONN_STRING   = "#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}"
            MONGODB_CONN_STRING = "mongodb://#{DB_CONN_STRING}"
            DB_SESSION_TABLE = 'rack_sessions'
            begin
              Mongo::Connection.from_uri(MONGODB_CONN_STRING, :timeout=>1)
            rescue Mongo::AuthenticationError 
              puts "Did you add #{DB_USER} to both dev and test databases? If not, please do."
              raise
            end
          end

at_exit do
  DB_CONN.close
end
  

DB = case ENV['RACK_ENV']
  
  when 'test'
    DB_CONN.db("megauni_test")
    
  when 'development'
    DB_CONN.db("megauni_dev")

  when 'production'
    DB_CONN.db(DB_NAME)

  else
    raise ArgumentError, "Unknown RACK_ENV value: #{ENV['RACK_ENV'].inspect}"

end # === case


module Couch_Plastic
  
  Not_Found               = Class.new(StandardError)
  HTTP_Error              = Class.new(StandardError)
  Time_Format             = '%Y-%m-%d %H:%M:%S'.freeze
  LANGS                   = eval(File.read(File.expand_path("helpers/langs_hash.rb")))
  
  Nothing_To_Update       = Class.new(StandardError)
  Raw_Data_Field_Required = Class.new(StandardError)
  Unauthorized            = Class.new(StandardError)
  
  class Invalid < StandardError
    attr_accessor :doc
    def initialize doc, msg=nil
      @doc = doc
      super(msg)
    end
  end


  attr_reader :data
  
  # =========================================================
  #                  self.included
  # ========================================================= 

  def self.included(target)
    target.extend Couch_Plastic_Class_Methods
  end
  
  def self.reset_db!
    valid_env = %w{ test development }.include?(ENV['RACK_ENV'])
    if not valid_env
      raise ArgumentError, "DB reseting only allowed in 'test' or 'development'."
    end
    
    DB.collection_names.reject { |name| name['system.'] }.each { |coll|
      DB.collection(coll).remove()
    }
    ensure_indexes
  end

  def self.ensure_indexes
    new = {}
    
    new['Clubs'] = [ 
      { 'unique' => true, 'key' => {'filename' => 1} }
    ]
    
    new['Member_Usernames'] = [
      { 'unique' => true, 'key' => {'username' => 1} }
    ]
    
    new['Messages'] = [
      { 'key' => {'published_at' => -1} }
    ]
    
    new['Messages'] = [
      { 'key' => {'target_ids' => 1, 'parent_message_id' => -1} }
    ]
    
    new['Message_Notifys'] = [
      { 'key' => { 'owner_id' => 1, 'message_id' => 1 } }
    ]
    
    new['Doc_Logs'] = [
      { 'key' => {'doc_id' => 1} }
    ]
    
    new.each { |coll, ixs| 
      index_info      = DB.collection(coll).index_information()
      index_info.delete '_id'
      index_info_vals = index_info.values
      slices          = index_info_vals.map { |i| { 'unique' => i['unique'], 'key'=> i['key'] } }

      delete = slices.each_index { |i|
        i_name = index_info_vals[i]['name']
        if i_name !~ /\A_id/ && !new[coll].include?( slices[i] )
          DB.collection(coll).drop_index(i_name)
        end
      }
      
      insert = new[coll].each_index { |i| 
        if not slices.include?( new[coll][i] )
          DB.collection(coll).create_index( new[coll][i]['key'].to_a, :unique=>new[coll][i]['unique'] , :background => true )
        end
      } 

    } 
  end

  def self.utc_now
    Time.now.utc.strftime(Time_Format)
  end

  def self.utc_date_now
    Time.now.utc.strftime(Time_Format.split(' ').first)
  end
  
  def self.utc_time_now
    Time.now.utc.strftime(Time_Format.split(' ').last)
  end
  
  def self.utc_string time_or_str
    time = case time_or_str
      when Time 
        time_or_str
      when String
        Time.parse(time_str)
    end
    time.strftime(Time_Format)
  end

  def self.mongofy_id raw_id
    return raw_id if raw_id.is_a?(BSON::ObjectID)
    return 'Nothing to see here' if raw_id.nil?
    return raw_id if not raw_id.is_a?(String)
    
    str = raw_id.strip
    return 'Nothing to see here' if str.empty?
    return str if not BSON::ObjectID.legal?(str)

    BSON::ObjectID.from_string(str)
  end

  def fetch( key )
    data.send key
  end
  
  def href 
    HREF_PATTERN.first % data.send(HREF_PATTERN.last) "/uni/#{data.filename}/"
  end
  alias_method :href_delete, :href

  def href_edit
    File.join(href, 'edit/' )
  end

  # 
  # Parameters:
  #   doc_id_or_hash - Optional. If String, used as a doc ID to
  #                    search. If Hash, used as original data.
  #
  def initialize doc_id_or_hash = nil, &blok
    
    super()
    @error_msg = nil # The efault error message for validation errors.
    @cache = {}
    doc   = case doc_id_or_hash
            when Hash
              doc_id_or_hash
            when nil
              nil
            else
              raise ArgumentError, "Unknown type for first argument: #{doc_id_or_hash.inspect}"
            end
      
    @data = doc && Data_Pouch.new(doc, self.class.fields.keys )
      

    if block_given?
      instance_eval(&blok)
    end

  end

  def find selector, params = {}, &blok
    raise "I don't know what to do with blocks." if block_given?
    db_coll = params.delete(:collection) || self.class.db_collection
    cache[db_coll]           ||= {}
    cache[db_coll][selector] ||= {}
    cache[db_coll][selector][params] ||= db_coll.find(selector, params, &blok).to_a
  end
  
  def find_one selector, params = {}, &blok
    raise "I don't know what to do with blocks." if block_given?
    
    params.delete('limit')
    params[:limit] = 1
    
    find(selector, params, &blok).first
  end

  def data?
    data && !data.as_hash.empty?
  end

  def new_data?
    !( new_data.as_hash.empty? || 
       new_data.as_hash == (data && data.as_hash)
     )
  end

  def new_data
    raise ArgumentError, "No new data." unless @new_data
    @new_data
  end

  def raw_data?
    @raw_data && !raw_data.empty?
  end
 
  def raw_data
    raise ArgumentError, "No raw data." unless @raw_data
    @raw_data
  end

  def generate_id
    set_id BSON::ObjectID.new 
  end
  
  def set_id new_id
    raise "New id can not be generated on an existing record." if not new?
    new_data._id = ( clean_date._id = new_id )
  end

  def clean_data
    raise ArgumentError, "No clean data." unless @clean_data
    @clean_data
  end

  def raw_data= raw_data
    @raw_data   = Data_Pouch.new(raw_data, self.class.fields.keys + self.class.psuedo_fields.keys)
    @clean_data = Data_Pouch.new({}, self.class.fields.keys + self.class.psuedo_fields.keys)
    @new_data   = Data_Pouch.new({}, self.class.fields.keys)

    @raw_data
  end

  def inspect
    "#<#{self.class}:#{self.object_id} id=#{self.data._id.inspect}>"
  end

  def == val
    return false unless val.respond_to?(:data)
    return true if equal?(val)
    return false if new? || val.new?
    data.as_hash == val.data.as_hash
  end

  def new?
    !data?
  end

  def clear_cache
    @cache = {}
  end

  def cache 
    @cache ||= {}
  end

  # ==== Authorizations ====
  
  def manipulator
    raise ArgumentError, "No manipulator set." unless @manipulator_set
    @manipulator
  end

  def manipulator= new_manipulator
    @manipulator_set = true
    @manipulator = new_manipulator
  end
  
  def owner? editor
    return false if not editor
    case editor
    when Member
      editor.lifes._ids.include?( data.owner_id ) || editor.has_power_of?(:ADMIN)
    when BSON::ObjectID
      match = data.owner_id == editor
      if not match
        match = begin
                  Member.by_id(editor).lifes._ids.include?(data.owner_id)
                rescue Member::Not_Found
                  false
                end
      end
      match
    end
  end

  # ==== Methods for handling Old/New Data

  def new_clean_value field_name, val
    
    setter = "#{field_name}="
    clean_data.send setter, val
    
    if new_data.respond_to?(setter)
      new_data.send setter, val
    else
      if not self.class.allowed_psuedo_field?(field_name)
        raise "Unknown field being set: #{field_name.inspect} (value: #{val.inspect})"
      end
    end
    
    val
    
  end

  def cleanest raw_field_name
    field_name = raw_field_name.to_s
    
    unless self.class.allowed_field?(field_name) || self.class.allowed_psuedo_field?(field_name)
      raise ArgumentError, "Field not allowed: #{field_name}" 
    end
    
    val = clean_data.send(field_name) 
    return val if val

    if new_data.respond_to?(field_name)
      new_data.send(field_name)
    end

    val
  end

  def lang_default
    (manipulator && manipulator.lang) || 'en-us'
  end

  def ask_for(*args)
    args.each { |raw_fld|
      fld = raw_fld.to_s
      if raw_data.send(fld)
        demand fld
      end
    }
  end

  def ask_for_or_default *args
    args.each { |raw_fld|
      fld = raw_fld.to_sym
      if raw_data.has_key?(fld)
        raw_data.send("#{fld}=", send("#{fld}_default"))
      end
      demand fld
    }
  end

  def demand(*args, &blok)
    
    if block_given?
      raise "this function's block handling functionality not implemented yet"
    else
      args.each { |raw_fld|
        
        fld = raw_fld.to_s
        def fld.humanize
          sub(/\A(add_|update_|create_)/, '').split('_').join(' ').capitalize
        end
        
        if not raw_data.has_key?(fld)
          raise Raw_Data_Field_Required, fld.inspect + " is required."
        end
        
        raw = raw_data.send(fld)

        (self.class.fields[fld] || self.class.psuedo_fields[fld]).each { |reg, target_val, err_msg| 
          
          case reg
            
          when :require_owner_as_manipulator
            manipulator.lifes._ids.include?(data.owner_id)

          when :set_to
            clean_val = instance_eval(&target_val)
            new_clean_value(fld, clean_val)

          when :set_raw_data
            field, process = target_val
            clean_val = instance_eval(&process)
            raw_data.send("#{field}=", clean_val)

          when :anything
            new_clean_value(fld, raw)
            
          when :array, :Array
            if raw.is_a?(Array)
              new_clean_value(fld, raw)
            else
              self.errors << (err_msg || @error_msg || "#{fld.capitalize} must be an array of values.")
            end
            
          when :hash, :Hash
            if raw.is_a?(Hash)
              new_clean_value(fld, raw)
            else
              self.errors << (err_msg || @error_msg || "#{fld.capitalize} is not a key/value data type.")
            end
            
          when :utc_now
            new_clean_value(fld, Couch_Plastic.utc_now)
              
          when :datetime_or_now
            new_val = begin
                        Time.parse(raw)
                      rescue ArgumentError
                        Couch_Plastic.utc_now
                      end
            new_clean_value(fld, new_val)
              
          when :equal
            val = case target_val
                  when Proc
                    instance_eval(&target_val)
                  else
                    target_val
                  end
            if raw.eql?(val)
              new_clean_value(fld, val)
            else
              self.errors << ( err_msg || @error_msg || "#{fld.humanize} does not match." )
            end
            
          when :error_msg
            @error_msg = target_val

          when :if_no_errors
            if errors.empty?
              instance_eval(&target_val)
            end
            
          when :integer
            raw = Integer(raw)
            new_clean_value fld, raw

          when :in_array
            arr = case target_val
                  when Proc
                    instance_eval(&target_val)
                  else
                    target_val
                  end
            if arr.include?(raw)
              new_clean_value fld, raw
            else
              errors << ( err_msg || @error_msg || "#{fld.humanize} is invalid: #{raw.inspect}" )
            end
            
          when :not_in_array
            arr = case target_val
                  when Proc
                    instance_eval(&target_val)
                  else
                    target_val
                  end
            if not arr.include?(raw)
              new_clean_value fld, raw
            else
              errors << ( err_msg || @error_msg || "#{fld.humanize} is not allowed: #{raw.inspect}" )
            end
            
          when :match
            if raw =~ target_val
              new_clean_value fld, raw
            else
              errors << ( err_msg || @error_msg || "#{fld.humanize} is invalid." )
            end
            
          when :max
            if (raw || raw.to_s).length <= target_val
              new_clean_value fld, raw
            else
              errors << (err_msg || @error_msg || "#{fld.humanize} can't be bigger than #{target_val} in size." )
            end

          when :min
            if (raw || raw.to_s).length >= target_val
              new_clean_value fld, raw
            else
              errors << (err_msg || @error_msg || "#{fld.humanize} must be at least #{target_val} characters long." )
            end
            
          when :mongo_object_id
            new_raw = if raw.is_a?(String) && BSON::ObjectID.legal?(raw)
                        BSON::ObjectID.from_string(raw)
                      else
                        raw
                      end
            if new_raw.is_a?(BSON::ObjectID)
              raw_data.send("#{fld}=", new_raw)
              new_clean_value fld, new_raw
              raw = new_raw
            else
              errors << (err_msg || @error_msg || "#{fld.humanize} is not a valid id.")
            end

          when :mongo_object_id_array
            is_array = raw.is_a?(Array)
            all_legal = is_array && [true] == raw.map { |v| v.is_a?(BSON::ObjectID) || BSON::ObjectID.legal?(v.to_s) }.uniq
            all_mongo = is_array && all_legal && raw.map { |v| 
              v.is_a?(BSON::ObjectID) ? v : BSON::ObjectID.from_string(v)
            }
            if all_mongo
              raw = all_mongo
              raw_data.send("#{fld}=", all_mongo)
              new_clean_value(fld, all_mongo)
            else
              self.errors << (err_msg || @error_msg || "#{fld.capitalize} has invalid values.")
            end


          when :not_empty
            if raw && (raw.is_a?(BSON::ObjectID) || !raw.empty?)
              new_clean_value fld, raw
            else
              errors << "#{fld.humanize} is required."
            end
            
          when :not_match
            val = case target_val
                  when Proc
                    instance(&target_val)
                  else
                    target_val
                  end
            match = case val
                    when Regexp
                      raw =~ val
                    else
                      raw.eql?(val)
                    end
            if not match
              new_clean_value fld, raw
            else
              errors << (err_msg || @error_msg || "#{fld.humanize} is invalid.")
            end

          when :split_and_flatten # Split on newline, then map split ','
            case raw
            when String
              arr = raw.split("\n").map {|piece| piece.split(',')}.flatten.map(&:strip)
              raw_data.send("#{fld}=", arr)
              raw = arr
              new_clean_value fld, arr
            when Array
              new_clean_value fld, raw
            when BSON::ObjectID
              raw = [raw]
              raw_data.send("#{fld}=", raw)
              new_clean_value fld, raw
            else
              errors << ( err_msg || @error_msg || "#{fld.humanize} is invalid.")
            end

          when :string
            case raw
            when String
              new_clean_value fld, raw
            else
              errors << (err_msg || @error_msg || "#{fld.humanize} is invalid.")
            end

          when :stripped
            case raw
            when String
              str = raw.to_s
              str = if err_msg
                      str.strip.gsub(target_val, &err_msg)
                    else 
                      str.strip.gsub(target_val, '')
                    end
              raw_data.send("#{fld}=", str)
              new_clean_value fld, str
            when NilClass
              nil
            else
              errors << (err_msg || @error_msg || "#{fld.humanize} is invalid." )
            end
            
          when :unique
            add_unique_key fld, (err_msg || @error_msg || "#{fld.humanize}, #{raw}, already taken. Please choose another.")
          else
            raise ArgumentError, "#{reg.inspect} is an invalid validation requirement."
          end
        }
        
      }
    end
  end
      
  # =========================================================
  #            Methods Related to Timestamps
  # ========================================================= 

  def last_modified_at
    return nil unless self.class.timestamps_enabled?
    updated_at || created_at
  end

  def created_at
    return nil unless self.class.allowed_field?('created_at')
    Time.parse(data.created_at)
  end

  def updated_at
    return nil unless self.class.allowed_field?('updated_at')
    return nil if data.updated_at.nil?
    Time.parse(data.updated_at)
  end
  
  
  # =========================================================
  #            Methods Related to DSL for Editors
  # ========================================================= 

  # =========================================================
  #               Save & Delete Methods
  # ========================================================= 


  # Accepts an optional block that is given, if any, a RestClient::RequestFailed
  # exception.  Use ".response.body" on the exception for JSON data.
  # Parameters:
  #   opts - Valid options: :if_valid, :on_error
  def save_create opts = {}

    raise "This is not a new document." if !new?

    clear_cache
    
    if !(allow_as_creator? manipulator)
      raise Unauthorized, "Creator: #{self.class} #{manipulator.inspect}"
    end
    
    raise_if_invalid
    demand 'created_at' if self.class.allowed_field?('created_at')

    new_data.data_model = self.class.name
    doc                = new_data.as_hash.clone

    err = nil
    if opts[:if_valid]
      begin
        opts[:if_valid].call(self)
      rescue Object
        err = $!
      end
    end

    err ||= begin
      doc.delete('_id') unless doc['_id']
      new_id = self.class.db_collection.insert( doc, :safe=>true )
      doc['_id'] = if new_id.is_a?(String) && BSON::ObjectID.legal?(new_id)
        BSON::ObjectID.from_string(new_id)
      else
        new_id
      end
      @data = Data_Pouch.new(doc, self.class.fields.keys )
      nil
    rescue Object
      $!
    end

    return self if not err
    
    # Check if keys need to be unique.
    if err.message =~ /duplicate key error/
      key, err_msg = unique_keys.detect { |k, v| 
        err.message =~ /\.\$#{Regexp.escape(k)}_/ 
      }
      if key
        errors << err_msg
        raise_if_invalid
      end
    end
    
    raise err
  end

  # Accepts an optional block that is given, if any, a RestClient::RequestFailed
  # exception.  Use ".response.body" on the exception for JSON data.
  # Parameters:
  #   opts - Valid options: :set_updated_at, :record_diff
  def save_update opts = {}, &blok

    clear_cache
    if !updator?(manipulator)
      raise Unauthorized, "Updator: #{self.class} #{manipulator.inspect}"
    end
    no_data = begin
                raise_if_invalid
                false
              rescue Couch_Plastic::Nothing_To_Update 
                $!
              end

    demand 'updated_at' if self.class.allowed_field?('updated_at')

    if opts[:if_valid]
      opts[:if_valid].call(self)
    end

    if no_data && opts[:if_valid]
      return self
    elsif no_data
      raise no_data
    end

    hsh = self.data.as_hash.clone.update(new_data.as_hash)

    id = data._id.to_s
    doc_id = if BSON::ObjectID.legal?(id)
               self.class.db_collection.update( {:_id=>BSON::ObjectID.from_string(id)}, hsh, :safe=>true )
             else
               self.class.db_collection.update( {:_id=>id}, hsh, :safe=>true)
             end
    
    if opts[:record_diff]
      o = data.as_hash.dup
      n = new_data.as_hash.dup
      
      Doc_Log.create( manipulator, 
        :doc_id  => data._id,
        :editor_id => raw_data.editor_id,
        :old_doc => o, 
        :new_doc => n
      )
    end

    data.as_hash.update(new_data.as_hash)

  end

  def delete!
    
    clear_cache

    results = Couch_Plastic.delete( data.id, data._rev )
    @data = nil # Mark document as new.

  end

  # =========================================================
  #                  Validator Helpers
  # ========================================================= 

  def errors
    @errors ||= []
  end

  def add_unique_key key_name, err_msg
    unique_keys[key_name.to_s] = err_msg
  end

  def unique_keys
    @unique_keys ||= {}
  end

  def raise_if_invalid
    
    if !errors.empty? 
      raise Invalid.new(self, "Document has validation errors: #{self.errors.join(' * ')}" )
    end

    if not new_data?
      raise Nothing_To_Update, "No new data to save."
    end

    true

  end 
  

end # === module Couch_Plastic ================================================


# =========================================================
# === Module: Class Methods for Couch_Plastic 
# ========================================================= 

module Couch_Plastic_Class_Methods 

  def db_collection
    @db_collection ||= DB.collection(name.to_s + 's')
  end

  # Example:
  #    arr = [ doc, doc, doc ]
  #    relationaize arr, Life, 'owner_id', 'username'=>'owner_username'
  # Each doc now has 'owner_username' added to it
  # from the Life class.
  # 
  # To include the entire doc, use a map of
  #     'key_name' => :doc
  #
  # Parameters: 
  #   fk => means foreign key
  #   field_map =>
  #      { 'username' => 'owner_username' }
  #    
  def relationize raw_coll, relation_class, fk, field_map
    coll   = raw_coll.to_a
    fks    = coll.map { |doc| doc[fk] }.uniq.compact
    f_docs = relation_class.find(:_id=>{ :$in => fks }).inject({}) { |m, doc|
      m[doc['_id']] = doc
      m
    }
    
    coll.map { |doc|
      target = f_docs[doc[fk]]
      field_map.each { | orig, namespaced |
        if namespaced == :doc
          doc[orig] = target
        else
          doc[namespaced] = if target
                              target[orig]
                            else
                              nil
                            end
        end
      }
      doc
    }
  end

  # ===== DSL-icious ======

  def fields_must_exist *flds
    raise(ArgumentError, "Empty array for fields.") if flds.empty?
    flds.each { |fld| 
      field_must_exist fld 
    }
  end

  def field_must_exist fld
    return true if allowed_field?(fld)
    raise ArgumentError, "Field does not exist: #{fld.inspect}"
  end

  def allowed_field? fld
    @fields.keys.include? fld
  end

  def fields 
    @fields ||= begin
                  {'_id' => [:not_empty], 'data_model' => [:not_empty], 'lang' => [ [:in_array, Couch_Plastic::LANGS]] }
                end
  end

  def allowed_psuedo_field? fld
    @psuedo_fields.keys.include? fld
  end

  def psuedo_fields
    @psuedo_fields ||= {}
  end

  def make raw_name, *regs
    name = raw_name.to_s.strip
    raise ArgumentError, "Field already set: #{name}" if fields[name]
    fields[name] ||= regs
  end

  def make_psuedo raw_name, *regs
    name = raw_name.to_s.strip
    raise ArgumentError, "Psuedo field already set: #{name}" if psuedo_fields[name]
    psuedo_fields[name] ||= regs
  end


  def enable_timestamps
    %w{ created_at updated_at }.each { |f| 
      make f, :utc_now
    }
  end

  def enable_created_at
    make 'created_at', :utc_now
  end

  def timestamps_enabled?
    allowed_field?('created_at') && allowed_field?('updated_at')
  end

  def associations
    @associations ||= {}
  end

  %{ has_many has_one, belongs_to }.each { |assoc|
    eval %~
      def #{assoc} name, class_name = nil, namespace = nil
        create_association( :#{assoc}, name, class_name, namespace)
      end
    
      def has_#{name}?
        raise "Not implemented yet."
      end
    
      def #{name}? target
        raise "This can only be called with :belongs_to association."
      end

      def update_relation name, obj
        raise "not done implemented yet."
      end
    ~
  }

  def create_association type, name, class_name = nil, namespace = nil
    meta           = Data_Pouch.new({}, :type, :name, :Class, :namespace)
    meta.type      = type
    meta.name      = name.to_sym
    meta.Class     = class_name || Object.const_get(name.to_s.capitalize),
    meta.namespace = namespace || meta.name
    
    if associations[meta.name]
      raise ArgumentError, "Association already defined: #{name}"
    end
    
    associations[meta.name] = meta
  end

  # ===== CRUD Methods ====================================

  def find_by_date field, start_tm, end_tm = nil
    time_format = '%Y-%m-%d %H:%M:%S'
    
    selector = if end_at
                 { field => {'$gt'=>start_tm,'$lt'=>end_tm} }
               else
                 { field => start_tm }
               end
    
    find selector
  end

  def find_with_associations raw_assocs, selector, params = {}
    assocs = [raw_assocs].flatten.uniq.compact
    docs = db_collection.find( selector, params ).to_a
    assocs.each { |rel|
      meta = associations[rel]
      meta[:class].relationize(docs, meta[:namespace])
    }
  end

  def find_by_field field, id, params = {}
    selector = { field => Couch_Plastic.mongofy_id(id) }
    find selector, params
  end

  def find_by_field_and_associate field, id, params = {}
    selector = { field => Couch_Plastic.mongofy_id(id) }
    find_with_associations associations.keys, selector, params
  end

  def find selector, params = {}, &blok
    if respond_to?(:selector_validation
      raise "not implemented yet."
    end
    fields = selector.keys
    fields_must_exist(fields) if not fields.empty?
    raise ArgumentError, "I don't know what to do with a block." if blok
    (params.delete(:collection) || db_collection).find(selector, params).to_a
  end
  
  def find_doc selector, params = {}
    raise ArgumentError, "I don't know what to do with a block." if block_given?
    params[:limit] = 1
    find(selector, params).first
  end
  
  def find_one *args
    raise ArgumentError, "No block allowed here." if block_given?
    doc = find_doc(*args)
    return new(doc) if doc
    raise self::Not_Found, args.to_a.map { |pair| "Document not found for: #{pair.first.capitalize}: #{pair.last}" }.join(', ')
  end

  def find_one_by_field
  def find_one_by_id( raw_id ) # READ
    id = Couch_Plastic.mongofy_id(raw_id)
    case id
    when BSON::ObjectID
      find_one( :_id => id )
    else
      find_one('old_id'=>doc_id_or_hash)
    end
  end

  def find_one_by_owner_id str, params = {}, opts = {}
    id = Couch_Plastic.mongofy_id(str)
    find({:owner_id=>str}.update(params), opts)
  end

  def create editor, raw_raw_data # CREATE
    new do
      self.manipulator =  editor
      self.raw_data = raw_raw_data
    end
  end

  def read id, mem # READ
    d = new(id) do
      if !d.reader?(mem)
        raise Unauthorized, "Reader: #{self.inspect} #{mem.inspect}"
      end
    end
    d
  end

  def edit id, mem # EDIT
    d = new(id) do 
      if !updator?(mem)
        raise Unauthorized, "Editor: #{self.inspect} #{mem.inspect}"
      end
    end
    d
  end

  def update id, editor, new_raw_data # UPDATE
    doc = new(id) do
      self.manipulator = editor
      self.raw_data = new_raw_data
      save_update 
    end
  end

  def delete id, editor # DELETE
    new(id) do
      self.manipulator = editor
      if !deletor?(editor)
        raise Unauthorized, "Deletor: #{self.class} #{manipulator.inspect}"
      end
      self.class.db_collection.remove({:_id=>data._id}, {:safe=>true})
    end
  end


end # === module ClassMethods ==============================================


__END__


  def related_collections *args
    args.each { |name|
      related_collection name
    }
  end

  def related_collection lower_case_name, full_name = nil
    full_name ||= "#{self}_#{lower_case_name.to_s.split('_').map(&:capitalize).join('_')}"
    eval %~
      def db_collection_#{lower_case_name}
        @coll_#{lower_case_name} ||= DB.collection('#{full_name}')
      end
      
      def find_#{lower_case_name} selector, params = {}, &blok
        params[:collection] = db_collection_#{lower_case_name}
        find selector, params, &blok
      end
      
      def find_one_#{lower_case_name} selector, params = {}, &blok
        params[:collection] = db_collection_#{lower_case_name}
        find_one selector, params, &blok
      end
    ~
    class_eval %~
      def find_#{lower_case_name} selector, params = {}, &blok
        params[:collection] = self.class.db_collection_#{lower_case_name}
        find(selector, params, &blok)
      end
        
      def find_one_#{lower_case_name} selector, params = {}, &blok
        params[:collection] = self.class.db_collection_#{lower_case_name}
        find_one(selector, params, &blok)
      end
    ~
  end



