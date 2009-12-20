require 'rack'
require 'rack/utils'
require 'views/Bunny_Mustache'

class The_Bunny
  
  # ======== CLASS stuff ======== 

	module Options
		ENVIRONS = [:development, :production, :test]
	end

	class << self
    
		Options::ENVIRONS.each { |envi|
			eval %~
				def #{envi}?
					ENV['RACK_ENV'] == '#{envi}'
				end
			~
		}

    def environment
      ENV['RACK_ENV']
    end

    def controllers
      @controllers ||= []
    end

	end

  def self.call(new_env)
    #
    # NOTE: 
    # For Thread safety in Rack, no instance variables should be changed.
    # Therefore, use :dup and a different version of :call
    # 
    the_app = new(new_env)
    status, header, body = the_app.response.finish

    # From The Sinatra Framework:
    #   Never produce a body on HEAD requests. Do retain the Content-Length
    #   unless it's "0", in which case we assume it was calculated erroneously
    #   for a manual HEAD response and remove it entirely.
    if new_env['REQUEST_METHOD'] == 'HEAD'
      body = []
      header.delete('Content-Length') if header['Content-Length'] == '0'
    end

    [status, header, body]
  end

  # ======== INSTANCE stuff ======== 
  
  include Rack::Utils
  attr_accessor :app, :env, :request, :response, :params
  attr_reader   :controller, :controller_name, :action_name 
  
  def initialize(new_env)
    @app      = self
    @env      = new_env
    @env      = new_env
    @request  = Rack::Request.new(@env)
    @response = Rack::Response.new

    begin
      
      run_the_request 
      
    rescue Bad_Bunny::Redirect
      
    rescue Bad_Bunny::HTTP_404
      
      @env['little.microphone.error'] = $!
      @response.status = 404
      @response.body   = '<h1>Not Found</h1>'
      
    rescue Object
      if The_Bunny
        raise $!
      end
      @env['little.microphone.error'] = $!
      error! '<h1>Unknown Error.</h1>'
      
    end
  end

  Options::ENVIRONS.each { |envir|
    %~
      def #{envir}?
        ENV['RACK_ENV'] == "#{envir}"
      end
    ~
  }
 
  def controller= class_obj
    @controller = class_obj
    @controller_name = class_obj.to_s.sub('_Bunny', '').to_sym
  end 

  def action_name= new_name
    @action_name = new_name.to_s.strip.sub('GET_','').to_sym
  end
  
  def environment 
    ENV['RACK_ENV']
  end

  def redirect! *args
    render_text_plain ''
    response.redirect *args
    raise Bad_Bunny::Redirect
  end

  def not_found! body
    error! body, 404
  end

  # Halt processing and return the error status provided.
  def error!(body, code = 500)
    response.status = code
    response.body   = body unless body.nil?
    raise Bad_Bunny.const_get("Error_#{code}")
  end

  def render_text_plain txt
    response.body = txt
    set_header 'Content-Type', 'text/plain; charset = utf-8'
    set_header 'Accept-Charset',   'utf-8'
    set_header 'Cache-Control',    'no-cache'
    set_header 'Pragma',           'no-cache'
  end

  def render_text_html txt
    response.body = txt
    set_header 'Content-Type',     'text/html; charset = utf-8'
    set_header 'Accept-Charset',   'utf-8'
    set_header 'Cache-Control',    'no-cache'
    set_header 'Pragma',           'no-cache'
  end


  def render_html_template obj, meth = nil
    meth_name        = meth || (caller[0] =~ /`([^']*)'/ && $1)
    file_name        = "#{controller_name}_#{action_name}"
    template_content = File.read(File.expand_path('templates/english/mustache/' + file_name + '.html'))
    
    require "views/#{file_name}.rb"
    view_class = Object.const_get(file_name)
    view_class.raise_on_context_miss = true
    html       = view_class.new(self).render( template_content )
    
    render_text_html(html)
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
    'Cache-Control',
    'Pragma'
    ]).uniq
  end

  def add_valid_header_key raw_key
    new_key = raw_key.to_s.strip
    @valid_header_keys = (valid_header_keys + [raw_key]).uniq
    new_key
  end

  def set_header key, raw_val 
    if !valid_header_keys.include?(key)
      raise ArgumentError, "Invalid header key: #{key.inspect}"
    end
    @response.header[key] = raw_val.to_s
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
  
  # ------------------------------------------------------------------------------------
  private # ----------------------------------------------------------------------------
  # ------------------------------------------------------------------------------------

  def respond_to_request? ctrl_class

    http_meth = env_key(:REQUEST_METHOD).to_s
    pieces    = env_key(:PATH_INFO).gsub(/\A\/|\/\Z/, '').split('/').map { |sub|
      sub.gsub(/[^a-zA-Z0-9_]/, '_') 
    }

    ctrlr, a_name, args = if env_key(:PATH_INFO) === '/'
      
      [ Bunny_DNA.controllers.first,  
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
      self.controller  = ctrlr
      self.action_name = a_name
      controller.new.send("#{http_meth}_#{action_name}", self, *args)
      return true
    end
      
    raise Bad_Bunny::HTTP_404, "Unable to process request: #{response.request_method} #{response.path}"
  end

  def run_the_request 
    
    the_app   = self
    http_meth = request.request_method
    results   = self.class.controllers.detect { |control|
      
      pieces  = request.path.strip_slashes.split('/')
      a_name  = http_meth
      
      begin
        
          pieces.shift if pieces.first == control.name.downcase
          pieces.push('list') if pieces.empty?
          a_name = [a_name, pieces.shift].compact.join('_')
          if control.public_instance_methods.include?(a_name) && 
             control.instance_method(a_name).arity === pieces.size + 1
            self.controller  = control
            self.action_name = a_name['_'] ? a_name.split("_")[1,100] : a_name
            control.new.send(a_name, self, *pieces)
            break
          end
          
      end until pieces.empty?

      self.controller

    }

    return true if results
    raise Bad_Bunny::HTTP_404, "Unable to process request: #{request.request_method} #{request.path}"

  end
end # ----- class Base * * * * * * * * * * * * * * * * * * * * * * * * * * * 

module Bad_Bunny
  HTTP_404      = Class.new(StandardError)
  Redirect      = Class.new(StandardError)
end # === Bad_Bunny


__END__

module Bunny_Cache_Controller

  # Specify response freshness policy for HTTP caches (Cache-Control header).
  # Any number of non-value directives (:public, :private, :no_cache,
  # :no_store, :must_revalidate, :proxy_revalidate) may be passed along with
  # a Hash of value directives (:max_age, :min_stale, :s_max_age).
  #
  #   cache_control :public, :must_revalidate, :max_age => 60
  #   => Cache-Control: public, must-revalidate, max-age=60
  #
  # See RFC 2616 / 14.9 for more on standard cache control directives:
  # http://tools.ietf.org/html/rfc2616#section-14.9.1
  def cache_control(*values)
    if values.last.kind_of?(Hash)
      hash = values.pop
      hash.reject! { |k,v| v == false }
      hash.reject! { |k,v| values << k if v == true }
    else
      hash = {}
    end

    values = values.map { |value| value.to_s.tr('_','-') }
    hash.each { |k,v| values << [k.to_s.tr('_', '-'), v].join('=') }

    response['Cache-Control'] = values.join(', ') if values.any?
  end

  # Set the Expires header and Cache-Control/max-age directive. Amount
  # can be an integer number of seconds in the future or a Time object
  # indicating when the response should be considered "stale". The remaining
  # "values" arguments are passed to the #cache_control helper:
  #
  #   expires 500, :public, :must_revalidate
  #   => Cache-Control: public, must-revalidate, max-age=60
  #   => Expires: Mon, 08 Jun 2009 08:50:17 GMT
  #
  def expires(amount, *values)
    values << {} unless values.last.kind_of?(Hash)

    if amount.respond_to?(:to_time)
      max_age = amount.to_time - Time.now
      time = amount.to_time
    else
      max_age = amount
      time = Time.now + amount
    end

    values.last.merge!(:max_age => max_age)
    cache_control(*values)

    response['Expires'] = time.httpdate
  end

  # Set the last modified time of the resource (HTTP 'Last-Modified' header)
  # and halt if conditional GET matches. The +time+ argument is a Time,
  # DateTime, or other object that responds to +to_time+.
  #
  # When the current request includes an 'If-Modified-Since' header that
  # matches the time specified, execution is immediately halted with a
  # '304 Not Modified' response.
  def last_modified(time)
    time = time.to_time if time.respond_to?(:to_time)
    time = time.httpdate if time.respond_to?(:httpdate)
    response['Last-Modified'] = time
    halt 304 if time == request.env['HTTP_IF_MODIFIED_SINCE']
    time
  end

  # Set the response entity tag (HTTP 'ETag' header) and halt if conditional
  # GET matches. The +value+ argument is an identifier that uniquely
  # identifies the current version of the resource. The +kind+ argument
  # indicates whether the etag should be used as a :strong (default) or :weak
  # cache validator.
  #
  # When the current request includes an 'If-None-Match' header with a
  # matching etag, execution is immediately halted. If the request method is
  # GET or HEAD, a '304 Not Modified' response is sent.
  def etag(value, kind=:strong)
    raise TypeError, ":strong or :weak expected" if ![:strong,:weak].include?(kind)
    value = '"%s"' % value
    value = 'W/' + value if kind == :weak
    response['ETag'] = value

    # Conditional GET check
    if etags = env['HTTP_IF_NONE_MATCH']
      etags = etags.split(/\s*,\s*/)
      halt 304 if etags.include?(value) || etags.include?('*')
    end
  end


end  # === module Bunny_Cache_Controller

module Bunny_Callers


  def dump_errors!(boom)
    trace = boom.backtrace
    backtrace = begin
                  unless settings.clean_trace?
                    trace
                  else
                    trace.reject { |line|
                      line =~ /lib\/sinatra.*\.rb/ ||
                        (defined?(Gem) && line.include?(Gem.dir))
                    }.map! { |line| line.gsub(/^\.\//, '') }
                  end
                end

    msg = ["#{boom.class} - #{boom.message}:",
      *backtrace].join("\n ")
    @env['rack.errors'].puts(msg)
  end
  CALLERS_TO_IGNORE = [
    /custom_require\.rb$/ # rubygems require hacks (Solution from Sinatra)
  ]

  # add rubinius (and hopefully other VM impls) ignore patterns ...
  CALLERS_TO_IGNORE.concat(RUBY_IGNORE_CALLERS) if defined?(RUBY_IGNORE_CALLERS)

  def clean_backtrace
    caller(1).
      map    { |line| line.split(/:(?=\d|in )/)[0,2] }.
      reject { |file,line| CALLERS_TO_IGNORE.any? { |pattern| file =~ pattern } }
  end

end # === Bunny_Callers -----------------------------------------------------


































__END__



Mini-Newspaper (for each life, each gets a custom debate page.)
  - Posts
    - view_id 
      1 - Public
      2 - Friends
      3 - Friends & Fans
      4 - Let me select audience:
  - PostComments [ "Important News", "A Random Thought"]
  - PostQuestions [ "Important Question", "A Silly Question" ]
  - PostViewers
  - club_id
  |
Network
  - TightPersons
  - LoosePersons
  - TightPersonInvite
  |
Clubs
  - TodoLists
  - Predictions
  - Questions
  - News (Debates)
  |
TODOS
  |
Pets
  |
Questions 
  |
Translation
  - to English
  - to Japanese
  |
Lunch Dating
  Find Breeder
  Find Partner
  Complain
  Advice/Tips/Warnings
  |
Housing
  Rent Out
  Find
  Mice
  Cleaning
  |
University
  Rate Professors
  Post Warnings/News
  Find/Create A College
  |
Blogs + Newspaper
  |
Travel & Dining
  Find a city
  Post a city
  |
News
  |
Layman Encyclopedia/Search (=Brain)
(Unify Wikipedia-Clone with Google-clone + Bing clone)
  |
Corporal Captitalists (bonds in working individuals)





# ------- TABLES ---------------------
NewsComments
  - news_id
  - status = PENDING || ACCEPTED || REJECTED
  - category = PRAISE || DENOUNCE || FACT CHECK || QUESTION || RANDOM
  - parent_id # for answering questions posted in the comments.
NewsCommentSections

News
  - parent_id # for news branching (predictions or responses).
  - language_id
  - category = DOINGS || NEWS || PREDICTIONS || OPINIONS || QUESTIONS
NewsEdits  




- version 1
  - site permission levels
    - admin
    - editor/moderator
    - unlimited invitations
  - multiple identities
  - pet profiles
    - med condition
  - baby profiles
    - med condition
  - pre-born profiles
    - names
  - fictional profiles
  - photo management
  - youtube linking
  - photo linking
  - guides/pamphlets
  - people mananagement
    - birthdays, anniversaries, important dates, repeating dates

  - Q&A
    - translations
    - vote best answer
    - competance weights
    
    
  - daily and onetime checklists
    - vitamins, etc.
    - countdowns, but no sound  
    - sharable
    - rules-based  
  - project management
    - due dates
      - status
    - milestones
    - files
  - office management
    - tweets
      - labels   
    - news
    - calendar
    - vote for best answer
      - translation
      - gardening
      - engineering
      - etc. 
      
  - invitations
    - gender
    - group
    
  - following
    - friends
    - fans
    - family
    - co-workers
    - frienemies
    - enemies
    - ex-lovers
    
  - tweets with labels   
    - No SMS for now.
   
    
    
- Future version   
  - bug tracking
  - visualize data stream (help handle data overload)
    - inspiration: plurk
  - email broadcasting
    - newsletters paid for 250 or above
  - video management
  - community management 
  - YouTube account connection  
  - Market 
    - local services
      - cleaning
      - food delivery  

  - reputation
    - import/export  
   
  - footprints
    - request to see profile
    - freind only profiles
  
  - universal language

- Create stories for learning alphabet and kanji characters
  - Video.
  - Slides.
- Vote on translations.
- Vote on pronounciation. (MP3/OggVorbis)


Future 
- Job board.
- Advice/Help section
- News section
- Video news w/translation.
- Postcard to Bill Sardi.     
