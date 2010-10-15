# MODULE templates/en-us/mab/extensions/MAB_Clubs_read_predictions.rb
# MAB   ~/megauni/templates/en-us/mab/Clubs_read_predictions.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_predictions.sass
# NAME  Clubs_read_predictions

require 'views/extensions/Base_Club'

class Clubs_read_predictions < Base_View

  include Views::Base_Club

  def title 
    return "Predictions: #{club_title}" unless club.is_a?(Life)
    "Predictions for #{club_filename}"
  end

  def predictions
    @predictions ||= compile_messages(app.env['results.predictions'])
  end
  
end # === Clubs_read_predictions 
