# === The most basic stuff first... ===

$KCODE = 'UTF8'
require 'jcode'

ENV['RACK_ENV'] ||= 'development'
require "always_verify_ssl_certificates"

require 'sinatra/base'
require 'mongo'
require 'mongo_rack'
require 'helpers/mongo_rack_with_proper_uri_parser'

  %w{
    Allow_Only_Roman_Uri
    Squeeze_Uri_Dots 
    Find_The_Bunny
    Always_Find_Favicon
    Slashify_Path_Ending
    Serve_Public_Folder
    Redirect_Mobile
    Catch_Bad_Bunny
    Email_Exception
    Strip_If_Head_Request
    Flash_Msg
    Mu_Archive_Redirect
  }.each { |middle|
    require "middleware/#{middle}"
  }

require 'helpers/app/kernel' 

# === Require configurations. ===
class Uni_App < Sinatra::Base
end # ===
require 'configs/Uni_App'
require 'configs/DB'

# === Require models. ===

%w{
  Doc_Log
  Club
  Message
  Member
}.each { |mod| require "models/#{mod}" }


# === Require controls. ===

%w{
  Base_Control
  Hellos
  Clubs
  Sessions
  Members
  Messages
}.each { |control|
  require "controls/#{control}"
}

# if Uni_App.development?
#   require "controls/Inspect_Control"
#   # Uni_App.controls << Inspect_Control
# end
  


