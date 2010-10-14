require 'views/Base_View'
require 'models/Hash_Sym_Or_Str_Keys'

module Base_Control

  # ======== Class Methods  ======== 
  class << self
    def included klass
      klass.extend Class_Methods
    end
  end # === class << self

  module Class_Methods
    def top_slash
      @path = '/'
    end
    def current_path
      @path
    end
    def path sub_path
      @path = sub_path
    end
    def get sub_path, &blok
      Uni_App.get File.join(current_path, sub_path, '/'), &blok
    end
  end # === module Class_Methods

  # ======== INSTANCE stuff ======== 
  
  include Rack::Utils
  attr_accessor :app, :env, :request, :response
  
  def initialize(new_env)
    @app      = self
    @env      = new_env
    @request  = Rack::Request.new(@env)
    @response = Rack::Response.new
  end
  
  def secure?
    (@env['HTTP_X_FORWARDED_PROTO'] || @env['rack.url_scheme']) == 'https'
  end

  # # NOTE:
  # # Returns original Hash from Rack::Request, without 
  # # symbolized keys.
  # #
  # # From: Sinatra
  # #   View original:
  # #   http://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb
  # def params
  #   @orig_params ||= begin
  #                      request.POST
  #                    rescue EOFError, Errno::ESPIPE
  #                      {}
  #                    end
  # end
  
  def control
    self
  end

  def control_name
    @control_name ||= self.class.to_s.sub('_Bunny', '').to_sym
  end

  def action_name
    @action_name ||= env['the.app.meta'][:action_name]
  end
  
  def clean_room
    @clean_room ||= begin
                        data = Hash_Sym_Or_Str_Keys.new
                        kv = if request.params.empty?
                               env['rack.request.form_hash'] || {}
                             else
                               request.params
                             end
                        kv.each { |k,v| 
                          data[k.to_s.strip] = case v
                          when String
                            temp = Loofah::Helpers.sanitize(v.strip)
                            temp.empty? ? nil : temp
                          when Array
                            v.map { |arr_v| 
                              Loofah::Helpers.sanitize(arr_v.strip)
                            }
                          else
                            raise "Unknown class: #{v.inspect} for #{k.inspect} in #{request.params.inspect}"
                          end
                        }
                        data
                      end
  end

  def lang
    'en-us'
  end
  
  def environment 
    ENV['RACK_ENV']
  end

  def redirect_back! *args
    args[0] = env['HTTP_REFERER'] || args[0]
    redirect! *args
  end

  def redirect! *args
    render_text_plain ''
    
    # If HTTP Code not specified, use 303.
    # This forces redirect as a GET.
    if not args.last.is_a?(Integer)
      args << 303 
    end
    
    response.redirect( *args )
    raise The_App::Redirect
  end

  def not_found! body
    error! body, 404
  end

  # Halt processing and return the error status provided.
  def error!(body, code = 500)
    response.status = code
    response.body   = body unless body.nil?
    raise The_App.const_get("HTTP_#{code}")
  end

  def render_application_xml txt
    response.body = txt
    set_header 'Content-Type', 'application/xml; charset=utf-8'
    set_header_if_nil 'Accept-Charset',   'utf-8'
    set_header_if_nil 'Cache-Control',    'no-cache'
  end

  def render_text_plain txt
    response.body = txt
    set_header 'Content-Type', 'text/plain; charset=utf-8'
    set_header_if_nil 'Accept-Charset',   'utf-8'
    set_header_if_nil 'Cache-Control',    'no-cache'
  end

  def render_text_html txt
    response.body = txt
    set_header 'Content-Type',     'text/html; charset = utf-8'
    set_header_if_nil 'Accept-Charset',   'utf-8'
    set_header_if_nil 'Cache-Control',    'no-cache'
  end

  def process_mustache ext = 'html', alt_file_name = nil
    
    file_name = alt_file_name || "#{control_name}_#{action_name}"
    mustache  = "templates/#{lang}/mustache/#{file_name}.#{ext}"
    template_content = if The_App.production? 
                         File.read(mustache)
                       else
                         disguise    = (ext == 'html' ? 'mab' : ext).capitalize
                         original    = "templates/#{lang}/#{disguise.downcase}/#{file_name}.rb"
                         time_format = '%M:%d:%H:%m:%Y'
                         
                         puts("Compiling templated instead of using cached Mustache...") if The_App.development?
                         require( "middleware/#{disguise}_In_Disguise"  )
                         disguise_class = Object.const_get( "#{disguise}_In_Disguise" )
                         disguise_class.compile_all(file_name)

                         Mustache::Generator.new.compile(
                           Mustache::Parser.new.compile(
                             disguise_class.compile( original ).to_s 
                           )
                         )
                       end
    
    require "views/#{file_name}.rb"
    view_class                       = Object.const_get(file_name)
    view_class.raise_on_context_miss = true
    ctx                              = Mustache::Context.new(view_class.new(self))
    eval(template_content, nil, file_name, 1)
  end

  def render_html_template *args
    render_text_html(
      process_mustache('html', *args)
    )
  end

  def render_xml_template
    render_application_xml(
      process_mustache('xml')
    )
  end
   
  def env_key raw_find_key
    find_key = raw_find_key.to_s.strip
    if @env.has_key?(find_key)
      return @env[find_key]
    end
    raise ArgumentError, "Key not found: #{find_key.inspect}"
  end

  def set_env_key find_key, new_value
    env_key find_key
    @env[find_key] = new_value
  end

  # Returns an array of acceptable media types for the response
  def allowed_mime_types
    @allowed_mime_types ||= @env['HTTP_ACCEPT'].to_s.split(',').map { |a| a.strip }
  end

  def ssl?
    (@env['HTTP_X_FORWARDED_PROTO'] || @env['rack.url_scheme']) === 'https'
  end
   
  def valid_header_keys
    @valid_header_keys ||= (@response.header.keys + [ 'Accept-Charset', 
    'Content-Disposition', 
    'Content-Type', 
    'Content-Length',
    'Cache-Control'
    ]).uniq
  end

  def require_valid_header_key key
    if !valid_header_keys.include?(key)
      raise ArgumentError, "Invalid header key: #{key.inspect}"
    end
    true
  end

  def add_valid_header_key raw_key
    new_key = raw_key.to_s.strip
    @valid_header_keys = (valid_header_keys + [raw_key]).uniq
    new_key
  end

  def header_set? key
    require_valid_header_key key
    @response.header.has_key?(key)
  end

  def get_header key
    require_valid_header_key key
    @response.header[key]
  end

  def set_header key, raw_val 
    require_valid_header_key key
    response[key] = raw_val.to_s
  end

  def set_header_if_nil key, raw_val
    require_valid_header_key key
    
    if @response.header.has_key?(key)
      response[key]
    else
      set_header key, raw_val
    end
  end

  # Set the Content-Type of the response body given a media type or file
  # extension.
  def set_content_type(mime_type, params={})
    if params.any?
      params = params.collect { |kv| "%s=%s" % kv }.join(', ')
      set_header 'Content-Type', [mime_type, params].join(";")
    else
      set_header 'Content-Type', mime_type
    end
  end

  # Set the Content-Disposition to "attachment" with the specified filename,
  # instructing the user agents to prompt to save.
  def set_attachment(filename)
    set_header 'Content-Disposition', 'attachment; filename="%s"' % File.basename(filename)
  end  

  # === Session-related helpers ===

  def session
    env['rack.session'] ||= {}
  end
  
  def flash_msg
    env['flash.msg']
  end

  def require_log_in! *perm_levels

    return true if perm_levels.empty? && logged_in?

    if not logged_in? 
      if request.get? || request.head? || !request.xhr?
        session[:return_page] = request.fullpath
        redirect!('/log-in/')
      elsif request.xhr?
        error! %~<div class="errors"> Not logged in. Log-in first and try again. </div>~, 401
      else
        raise "This part of the app not finished."   
      end
    end

    power = perm_levels.detect { |level| 
              current_member.has_power_of?(level) 
            }
            
    if not power
      error!( nil, 403)
    end
 
    true
  end 
  
  def log_out!
    return_page = session.delete(:return_page)
    session.clear
    session[:return_page] = return_page
  end 
  
  def logged_in?
    session[:member_id] && current_member && !current_member.new?
  end # === def      

  def current_member=(mem)
    raise "CURRENT MEMBER ALREADY SET" if logged_in?
    session[:member_id] = mem.data._id
  end    

  def current_member
    return nil if !session[:member_id]
    @current_member ||= Member.by_id( session[:member_id] )
  end # === def
  
  
  # ------------------------------------------------------------------------------------
  private # ----------------------------------------------------------------------------
  # ------------------------------------------------------------------------------------

  def respond_to_request? ctrl_class

    http_meth = env_key(:REQUEST_METHOD).to_s
    pieces    = env_key(:PATH_INFO).gsub(/\A\/|\/\Z/, '').split('/').map { |sub|
      sub.gsub(/[^a-zA-Z0-9_]/, '_') 
    }

    ctrlr, a_name, args = if env_key(:PATH_INFO) === '/'
      
      [ Bunny_DNA.controls.first,  
        'list',
        []
      ]
      
    else
      
      mic_class_name = pieces.shift.
                        split('_').
                        map(&:capitalize).
                        join('_') + 
                        mic_class_name_suffix

      if Object.const_defined?(mic_class_name)
        
        mic_class   = Object.const_get(mic_class_name)
        action_name = [ http_meth , pieces.first ].compact.join('_')
        meth        = pieces.first ? pieces.first.to_s.gsub(/[^a-zA-Z0-9_]/, '_') : 'NONE'
      
        
        if pieces.empty? && 
           request.get? &&
           mic_class.public_instance_methods.include?('GET_list')
          
           [ mic_class, 'list', [] ]
          
        elsif mic_class.public_instance_methods.include?(action_name) &&
              mic_class.instance_method(action_name).arity === (pieces.empty? ? 1 : pieces.size )

          pieces.shift
          [ mic_class, meth, pieces ]
          
        elsif mic_class.public_instance_methods.include?(http_meth) &&
              mic_class.instance_method(http_meth).arity === (pieces.size + 1)

          [ mic_class, http_meth, pieces ]
          
        end

      else
        []
      end

    end   
    
    if ctrlr && a_name && args
      self.control  = ctrlr
      self.action_name = a_name
      control.new.send("#{http_meth}_#{action_name}", self, *args)
      return true
    end
      
    raise The_App::HTTP_404, "Unable to process request: #{response.request_method} #{response.path}"
  end

  def handle_rest args = {}
    assert_valid_keys args, [:params, :action_name]
    args[:params] ||= clean_room
    args[:action_name] ||= action_name

    model_class = Object.const_get(self.class.sub('_control'))
    case args[:action_name]
      when :GET_new # new
        raise "not done"
      when :GET_edit # edit
        raise "not done"
      when :POST # create
        raise "not done"
      when :PUT # update
        raise "not done"
      when :DELETE
        raise "not done"
    end
  end

  def success_msg *args
    return @success_msg if args.empty?
    @success_msg = args.first
  end

end # === Base_Control





 #  ============================================================================================================================
 #  ============================================================================================================================
 #  ============================================================================================================================
 #  ============================================================================================================================
 #  ============================================================================================================================
 #  ============================================================================================================================
 #  ============================================================================================================================





module Sinatra
  module Uni_Base_Helper


  # ======== INSTANCE stuff ======== 
  
  # include Rack::Utils
  # attr_accessor :app, :env, :request, :response
  
  # def initialize(new_env)
  #   @app      = self
  #   @env      = new_env
  #   @request  = Rack::Request.new(@env)
  #   @response = Rack::Response.new
  # end
  
  # def secure?
  #   (@env['HTTP_X_FORWARDED_PROTO'] || @env['rack.url_scheme']) == 'https'
  # end

  # # NOTE:
  # # Returns original Hash from Rack::Request, without 
  # # symbolized keys.
  # #
  # # From: Sinatra
  # #   View original:
  # #   http://github.com/sinatra/sinatra/blob/master/lib/sinatra/base.rb
  # def params
  #   @orig_params ||= begin
  #                      request.POST
  #                    rescue EOFError, Errno::ESPIPE
  #                      {}
  #                    end
  # end
  
  def control
    self
  end

  def control_name
    @control_name ||= self.class.to_s.sub('_Bunny', '').to_sym
  end

  def action_name
    @action_name ||= env['the.app.meta'][:action_name]
  end
  
  def clean_room
    @clean_room ||= begin
                        data = Hash_Sym_Or_Str_Keys.new
                        kv = if request.params.empty?
                               env['rack.request.form_hash'] || {}
                             else
                               request.params
                             end
                        kv.each { |k,v| 
                          data[k.to_s.strip] = case v
                          when String
                            temp = Loofah::Helpers.sanitize(v.strip)
                            temp.empty? ? nil : temp
                          when Array
                            v.map { |arr_v| 
                              Loofah::Helpers.sanitize(arr_v.strip)
                            }
                          else
                            raise "Unknown class: #{v.inspect} for #{k.inspect} in #{request.params.inspect}"
                          end
                        }
                        data
                      end
  end

  def lang
    'en-us'
  end
  
  def environment 
    ENV['RACK_ENV']
  end

  def redirect_back! *args
    args[0] = env['HTTP_REFERER'] || args[0]
    redirect! *args
  end

  def redirect! *args
    render_text_plain ''
    
    # If HTTP Code not specified, use 303.
    # This forces redirect as a GET.
    if not args.last.is_a?(Integer)
      args << 303 
    end
    
    response.redirect( *args )
    raise The_App::Redirect
  end

  def not_found! body
    error! body, 404
  end

  # Halt processing and return the error status provided.
  def error!(body, code = 500)
    response.status = code
    response.body   = body unless body.nil?
    raise The_App.const_get("HTTP_#{code}")
  end

  def render_application_xml txt
    response.body = txt
    set_header 'Content-Type', 'application/xml; charset=utf-8'
    set_header_if_nil 'Accept-Charset',   'utf-8'
    set_header_if_nil 'Cache-Control',    'no-cache'
  end

  def render_text_plain txt
    response.body = txt
    set_header 'Content-Type', 'text/plain; charset=utf-8'
    set_header_if_nil 'Accept-Charset',   'utf-8'
    set_header_if_nil 'Cache-Control',    'no-cache'
  end

  def render_text_html txt
    response.body = txt
    set_header 'Content-Type',     'text/html; charset = utf-8'
    set_header_if_nil 'Accept-Charset',   'utf-8'
    set_header_if_nil 'Cache-Control',    'no-cache'
  end

  def process_mustache ext = 'html', alt_file_name = nil
    
    file_name = alt_file_name || "#{control_name}_#{action_name}"
    mustache  = "templates/#{lang}/mustache/#{file_name}.#{ext}"
    template_content = if The_App.production? 
                         File.read(mustache)
                       else
                         disguise    = (ext == 'html' ? 'mab' : ext).capitalize
                         original    = "templates/#{lang}/#{disguise.downcase}/#{file_name}.rb"
                         time_format = '%M:%d:%H:%m:%Y'
                         
                         puts("Compiling templated instead of using cached Mustache...") if The_App.development?
                         require( "middleware/#{disguise}_In_Disguise"  )
                         disguise_class = Object.const_get( "#{disguise}_In_Disguise" )
                         disguise_class.compile_all(file_name)

                         Mustache::Generator.new.compile(
                           Mustache::Parser.new.compile(
                             disguise_class.compile( original ).to_s 
                           )
                         )
                       end
    
    require "views/#{file_name}.rb"
    view_class                       = Object.const_get(file_name)
    view_class.raise_on_context_miss = true
    ctx                              = Mustache::Context.new(view_class.new(self))
    eval(template_content, nil, file_name, 1)
  end

  def render_html_template *args
    render_text_html(
      process_mustache('html', *args)
    )
  end

  def render_xml_template
    render_application_xml(
      process_mustache('xml')
    )
  end
   
  def env_key raw_find_key
    find_key = raw_find_key.to_s.strip
    if @env.has_key?(find_key)
      return @env[find_key]
    end
    raise ArgumentError, "Key not found: #{find_key.inspect}"
  end

  def set_env_key find_key, new_value
    env_key find_key
    @env[find_key] = new_value
  end

  # Returns an array of acceptable media types for the response
  def allowed_mime_types
    @allowed_mime_types ||= @env['HTTP_ACCEPT'].to_s.split(',').map { |a| a.strip }
  end

  def ssl?
    (@env['HTTP_X_FORWARDED_PROTO'] || @env['rack.url_scheme']) === 'https'
  end
   
  def valid_header_keys
    @valid_header_keys ||= (@response.header.keys + [ 'Accept-Charset', 
    'Content-Disposition', 
    'Content-Type', 
    'Content-Length',
    'Cache-Control'
    ]).uniq
  end

  def require_valid_header_key key
    if !valid_header_keys.include?(key)
      raise ArgumentError, "Invalid header key: #{key.inspect}"
    end
    true
  end

  def add_valid_header_key raw_key
    new_key = raw_key.to_s.strip
    @valid_header_keys = (valid_header_keys + [raw_key]).uniq
    new_key
  end

  def header_set? key
    require_valid_header_key key
    @response.header.has_key?(key)
  end

  def get_header key
    require_valid_header_key key
    @response.header[key]
  end

  def set_header key, raw_val 
    require_valid_header_key key
    response[key] = raw_val.to_s
  end

  def set_header_if_nil key, raw_val
    require_valid_header_key key
    
    if response.header.has_key?(key)
      response[key]
    else
      set_header key, raw_val
    end
  end

  # Set the Content-Type of the response body given a media type or file
  # extension.
  def set_content_type(mime_type, params={})
    if params.any?
      params = params.collect { |kv| "%s=%s" % kv }.join(', ')
      set_header 'Content-Type', [mime_type, params].join(";")
    else
      set_header 'Content-Type', mime_type
    end
  end

  # Set the Content-Disposition to "attachment" with the specified filename,
  # instructing the user agents to prompt to save.
  def set_attachment(filename)
    set_header 'Content-Disposition', 'attachment; filename="%s"' % File.basename(filename)
  end  

  # === Session-related helpers ===

  def session
    env['rack.session'] ||= {}
  end
  
  def flash_msg
    env['flash.msg']
  end

  def require_log_in! *perm_levels

    return true if perm_levels.empty? && logged_in?

    if not logged_in? 
      if request.get? || request.head? || !request.xhr?
        session[:return_page] = request.fullpath
        redirect!('/log-in/')
      elsif request.xhr?
        error! %~<div class="errors"> Not logged in. Log-in first and try again. </div>~, 401
      else
        raise "This part of the app not finished."   
      end
    end

    power = perm_levels.detect { |level| 
              current_member.has_power_of?(level) 
            }
            
    if not power
      error!( nil, 403)
    end
 
    true
  end 
  
  def log_out!
    return_page = session.delete(:return_page)
    session.clear
    session[:return_page] = return_page
  end 
  
  def logged_in?
    session[:member_id] && current_member && !current_member.new?
  end # === def      

  def current_member=(mem)
    raise "CURRENT MEMBER ALREADY SET" if logged_in?
    session[:member_id] = mem.data._id
  end    

  def current_member
    return nil if !session[:member_id]
    @current_member ||= Member.by_id( session[:member_id] )
  end # === def
  
  
  # ------------------------------------------------------------------------------------
  private # ----------------------------------------------------------------------------
  # ------------------------------------------------------------------------------------

  def respond_to_request? ctrl_class

    http_meth = env_key(:REQUEST_METHOD).to_s
    pieces    = env_key(:PATH_INFO).gsub(/\A\/|\/\Z/, '').split('/').map { |sub|
      sub.gsub(/[^a-zA-Z0-9_]/, '_') 
    }

    ctrlr, a_name, args = if env_key(:PATH_INFO) === '/'
      
      [ Bunny_DNA.controls.first,  
        'list',
        []
      ]
      
    else
      
      mic_class_name = pieces.shift.
                        split('_').
                        map(&:capitalize).
                        join('_') + 
                        mic_class_name_suffix

      if Object.const_defined?(mic_class_name)
        
        mic_class   = Object.const_get(mic_class_name)
        action_name = [ http_meth , pieces.first ].compact.join('_')
        meth        = pieces.first ? pieces.first.to_s.gsub(/[^a-zA-Z0-9_]/, '_') : 'NONE'
      
        
        if pieces.empty? && 
           request.get? &&
           mic_class.public_instance_methods.include?('GET_list')
          
           [ mic_class, 'list', [] ]
          
        elsif mic_class.public_instance_methods.include?(action_name) &&
              mic_class.instance_method(action_name).arity === (pieces.empty? ? 1 : pieces.size )

          pieces.shift
          [ mic_class, meth, pieces ]
          
        elsif mic_class.public_instance_methods.include?(http_meth) &&
              mic_class.instance_method(http_meth).arity === (pieces.size + 1)

          [ mic_class, http_meth, pieces ]
          
        end

      else
        []
      end

    end   
    
    if ctrlr && a_name && args
      self.control  = ctrlr
      self.action_name = a_name
      control.new.send("#{http_meth}_#{action_name}", self, *args)
      return true
    end
      
    raise The_App::HTTP_404, "Unable to process request: #{response.request_method} #{response.path}"
  end

  def handle_rest args = {}
    assert_valid_keys args, [:params, :action_name]
    args[:params] ||= clean_room
    args[:action_name] ||= action_name

    model_class = Object.const_get(self.class.sub('_control'))
    case args[:action_name]
      when :GET_new # new
        raise "not done"
      when :GET_edit # edit
        raise "not done"
      when :POST # create
        raise "not done"
      when :PUT # update
        raise "not done"
      when :DELETE
        raise "not done"
    end
  end

  def success_msg *args
    return @success_msg if args.empty?
    @success_msg = args.first
  end
    def uni(text)
      Rack::Utils.escape_html(text)
    end

  end # === module Uni_Base_Helper
  
  helpers Uni_Base_Helper
end # === Sinatra

module Sinatra
  module HTMLEscapeHelper
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end

  helpers HTMLEscapeHelper
end
