
ENV['RACK_ENV'] ||= 'production'

require 'rack/protection'
require 'securerandom'
require './Server/main'

require "./middleware/Squeeze_Uri_Dots"

# === Protective

class Da_Middles
  def initialize main_app
    puts main_app.inspect
    @app = Rack::Builder.new do

      use Rack::ContentLength
      use Rack::Session::Cookie, secret: SecureRandom.urlsafe_base64(nil, true)
      use Rack::Protection

      if ENV['IS_DEV']
        use Rack::CommonLogger
        use Rack::ShowExceptions
      end

      use Squeeze_Uri_Dots

      run main_app
    end
  end

  def call env
    @app.call env
  end
end


use Da_Middles
use Rack::Lint
run Cuba


# %w{

  # Allow_Only_Roman_Uri

  # Squeeze_Uri_Dots

  # Surfer_Hearts_Archive

  # Always_Find_Favicon

  # Slashify_Path_Ending

  # Redirect_Mobile

  # Strip_If_Head_Request

  # Mu_Archive_Redirect

  # Mu_Archive

# }.each { |name|
  # require "./middleware/#{name}"
  # use Object.const_get(name)
# }

# require './middleware/Public_Files'
# use Public_Files, ['public/busy-noise', 'public/my-egg-timer', 'public/styles', 'public/skins', Mu_Archive::Dir, Surfer_Hearts_Archive::Dir]

# # === Content Generators

# # === Helpers
# use Rack::MethodOverride

# # === Low-level Helpers
# # === (specifically designed to run before Uni_App).

# # Finally, start the app.
# run Cuba


