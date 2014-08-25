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
  
# -------------- NEWER CODE -----------------------------
%w{

   Surfer_Hearts_Archive

   Redirect_Mobile

   Mu_Archive_Redirect

   Mu_Archive

}.each { |name|
 require "./middleware/#{name}"
 use Object.const_get(name)
}

require './middleware/Public_Files'
use Public_Files, ['public/busy-noise', 'public/my-egg-timer', 'public/styles', 'public/skins', Mu_Archive::Dir, Surfer_Hearts_Archive::Dir]

# === Content Generators

# === Helpers
use Rack::MethodOverride

# === Low-level Helpers
# === (specifically designed to run before Uni_App).

# Finally, start the app.
run Cuba




  post "/search/" do 
    name = params['name'] || params['keyword']
    retro = "/#{name}/"
    redirect(to("/#{name}/"), Perma) if Mu_Archive(retro)

    case name
    when %r!menop..se!, %r!ost[eo]+p[oris]+!
      redirect to("/meno-osteo/"), Perma
    else
      Mu_Archive_Read "/search/index.html", :name=>name
    end
  end # === post search

  post "/club-search/" do
    redirect to("/search/"), Perma
  end



