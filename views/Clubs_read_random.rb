# MAB   ~/megauni/templates/en-us/html/Clubs_read_random.rb
# SASS  ~/megauni/templates/en-us/css/Clubs_read_random.sass
# NAME  Clubs_read_random

require 'views/extensions/Base_Club'

class Clubs_read_random < Base_View
  
  include Views::Base_Club

  def title 
    return "Random: #{club_title}" unless club.is_a?(Life)
    "#{club_filename}'s Random Thoughts & Babble"
  end

  def randoms
    @randoms ||= compile_messages(app.the.randoms )
  end
  
end # === Clubs_read_random 
