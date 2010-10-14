# === The most basic stuff first... ===

$KCODE = 'UTF8'
ENV['RACK_ENV'] ||= 'development'

require 'jcode'
require 'sinatra/base'
require 'helpers/app/kernel' 
require 'mongo'

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
}.each { |control|
  require "controls/#{control}"
}

# if Uni_App.development?
#   require "controls/Inspect_Control"
#   # Uni_App.controls << Inspect_Control
# end
  


