
ENV['RACK_ENV'] ||= 'production'

require 'rack/protection'
require 'securerandom'
require './Server/main'


# === Protective

class Da_Middles
end


use Da_Middles
use Rack::Lint
run Cuba


# %w{

  # Surfer_Hearts_Archive

  # Redirect_Mobile

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


