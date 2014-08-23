
ENV['RACK_ENV'] ||= 'production'

require './megauni'

my_app_root     = File.expand_path( File.dirname(__FILE__) )
down_time_file  = File.join( my_app_root, '/helpers/sinatra/maintain')
issue_client    = File.join( my_app_root, '/helpers/app/issue_client')


# === Protective

use Rack::Lint
use Rack::ContentLength

if The_App.development?
  use Rack::CommonLogger
  use Rack::ShowExceptions
end

require "./middleware/Custom_Errors"
use Custom_Errors, The_App::HTTP_Status_Error

%w{

  Allow_Only_Roman_Uri

  Squeeze_Uri_Dots

  Surfer_Hearts_Archive

  Always_Find_Favicon

  Slashify_Path_Ending

  Redirect_Mobile

  Strip_If_Head_Request

  Mu_Archive_Redirect

  Mu_Archive

}.each { |name|
  require "./middleware/#{name}"
  use Object.const_get(name)
}

require './middleware/Public_Files'
use Public_Files, ['public/busy-noise', 'public/my-egg-timer', 'public/styles', 'public/skins', Mu_Archive::Dir, Surfer_Hearts_Archive::Dir]

# === Content Generators
# use Always_Find_Favicon

# === Helpers
use Rack::MethodOverride
# use Rack::Session::Mongo, {:server=>File.join( ENV['MONGO_DB'], DB_SESSION_TABLE ) , :expire_after => (60*60*24*14) }
# use Strip_If_Head_Request

# === Low-level Helpers
# === (specifically designed to run before Uni_App).

# unless Uni_App.development?
#   use Email_Exception
#   # use Catch_Bad_Bunny
#   # use Find_The_Bunny
# end

# use Flash_Msg

# Finally, start the app.
run The_App
require './da'
run Cuba
