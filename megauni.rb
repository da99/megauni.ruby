
$KCODE = 'UTF8'
ENV['RACK_ENV'] ||= 'development'

require 'jcode'
require 'sinatra/base'
	
require 'helpers/app/kernel' 
require 'middleware/The_App'  
require 'mongo'

class The_App
  
  SITE_DOMAIN        = 'megaUni.com'
  SITE_TITLE         = 'megaUNI'
  SITE_NAME          = 'megaUNI'
  SITE_TAG_LINE      = "Create universes."
  SITE_HELP_EMAIL    = "help@#{SITE_DOMAIN}"
  SITE_URL           = "http://www.#{SITE_DOMAIN}/"
  ON_HEROKU          = ENV.keys.grep(/heroku/i).size > 0
end # === class

if The_App::ON_HEROKU
  class The_App
    SMTP_AUTHENTICATION = :plain 
    SMTP_ADDRESS   = 'smtp.sendgrid.net'
    SMTP_USER_NAME = ENV['SENDGRID_USERNAME']
    SMTP_PASSWORD  = ENV['SENDGRID_PASSWORD']
    SMTP_DOMAIN    = ENV['SENDGRID_DOMAIN']
  end
else
  class The_App
    SMTP_AUTHENTICATION = :plain 
    SMTP_ADDRESS   = 'unknown'
    SMTP_USER_NAME = 'username'
    SMTP_PASSWORD  = 'password'
    SMTP_DOMAIN    = 'unknown'
  end
end

# === DB urls/connections ===
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


# === Require models. ===

%w{
  Mongo_Dsl
  Doc_Log
  Club
  Message
  Member
}.each { |mod| require "models/#{mod}" }


  # ===============================================
  # Require these controls.
  # ===============================================
	class Uni_App < Sinatra::Base
		helpers Sinatra::Uni_Base_Helper
		helpers Sinatra::HTMLEscapeHelper
	end # === Uni_App

  #   Sessions
  #   Members
  #   Clubs
  #   Messages
  %w{
    Hellos
  }.each { |control|
    require "controls/#{control}"
  #   # The_App.controls << Object.const_get(control)
  }

  if The_App.development?
    require "controls/Inspect_Control"
    # The_App.controls << Inspect_Control
  end
	


