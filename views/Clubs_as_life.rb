# MAB     ~/megauni/templates/en-us/mab/Clubs_as_life.rb
# MODULE  ~/megauni/templates/en-us/mab/extensions/MAB_Clubs_as_life.rb
# SASS    ~/megauni/templates/en-us/sass/Clubs_as_life.sass
# NAME    as_life
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

require 'views/extensions/Base_Club'

class Clubs_as_life < Base_View
 
  include Views::Base_Club

  def title 
    "The Life of #{app.the.club.data}"
  end
  
end # === as_life 
