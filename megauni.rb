# === The most basic stuff first... ===

$KCODE = 'UTF8'
ENV['RACK_ENV'] ||= 'development'
require 'jcode'
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
    Old_App_Redirect
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
  Mongo_Dsl
  Doc_Log
  Club
  Message
  Member
}.each { |mod| require "models/#{mod}" }


# === Require controls. ===

#   Sessions
#   Members
#   Clubs
#   Messages
%w{
  Base_Control
  Hellos
  Clubs
}.each { |control|
  require "controls/#{control}"
}

# if Uni_App.development?
#   require "controls/Inspect_Control"
#   # Uni_App.controls << Inspect_Control
# end
  


