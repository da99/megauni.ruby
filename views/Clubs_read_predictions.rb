# MODULE templates/en-us/html/extensions/MAB_Clubs_read_predictions.rb
# MAB   ~/megauni/templates/en-us/html/Clubs_read_predictions.rb
# SASS  ~/megauni/templates/en-us/css/Clubs_read_predictions.sass
# NAME  Clubs_read_predictions

require 'views/extensions/Base_Club'

class Clubs_read_predictions < Base_View

  include Views::Base_Club

  def title 
    return "Predictions: #{club_title}" unless club.is_a?(Life)
    "Predictions for #{club_filename}"
  end

  def predictions
    @predictions ||= compile_messages(app.the.predictions )
  end
  
end # === Clubs_read_predictions 
