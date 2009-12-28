
$KCODE = 'UTF8'
ENV['RACK_ENV'] ||= 'development'

require 'jcode'

# ===============================================
# Important Gems
# ===============================================
require 'multibyte'
require 'cgi' # Don't use URI.escape because it does not escape all invalid characters.
require 'rest_client'

  # ===============================================
  # App Helpers
  # ===============================================
  require( 'helpers/app/require'  )
  require_these 'helpers/app', %w{
    kernel
    chars_compat
    string_additions
    string_blank
    string_inflections
    read_if_file
    symbolize_keys
    json
    data_pouch
    cleaner_dsl
    demand_arguments_dsl
  }
  

  DESIGN_DOC_ID      = '_design/megauni'
  
  require 'middleware/The_Bunny_Farm'  

  class The_Bunny_Farm
    
    module Options
      SITE_DOMAIN        = 'megaUni.com'
      SITE_TITLE         = 'Mega Uni'
      SITE_TAG_LINE      = 'For all your different lives: friends, family, work.'
      SITE_HELP_EMAIL    = "helpme@#{SITE_DOMAIN}"
      SITE_URL           = "http://www.#{SITE_DOMAIN}/"
      SITE_SUPPORT_EMAIL = "helpme@#{SITE_DOMAIN}"
      VIEWS_DIR          = 'views/skins/jinx' # .expand_path
			SITE_KEYWORDS      = 'office games'
			LANGUAGES          = ['English']
    end
    
  end # === class

  case ENV['RACK_ENV']
    
    when 'test'
        CouchDB_URI = "https://da01tv:isleparadise4vr@localhost"
        DB_NAME     = 'megauni-test'
        DB_CONN     = File.join(CouchDB_URI, DB_NAME)     
      
    when 'development'
      CouchDB_URI = "https://da01tv:isleparadise4vr@localhost"
      DB_NAME     = "megauni-dev"
      DB_CONN     = File.join( CouchDB_URI, DB_NAME )

    when 'production'
      CouchDB_URI = "http://un**:pswd**@127.0.0.1:5984/"
      DB_NAME     = 'megauni-production'
      DB_CONN     = File.join(CouchDB_URI, DB_NAME)


    else
      raise ArgumentError, "Unknown RACK_ENV value: #{ENV['RACK_ENV'].inspect}"

  end # === case
  
  %w{
    Hello
    Session_Cage
    Member_Cage   
    Topic
    Club_Cage
  }.each { |control|
		require "controls/#{control}"
		The_Bunny_Farm.controls << Object.const_get(control)
	}

  if The_Bunny_Farm.development?
    require "controls/Inspect_Cage"
    The_Bunny_Farm.controls << Inspect_Cage
  end
 
  # ===============================================
  # Require Models.
  # ===============================================
  require_these 'models', %w{
    Couch_Doc
    Design_Doc
    Couch_Plastic
    Club
    News
  }     # resty
    # Member
    # log_in_attempt
