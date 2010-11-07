# MAB   ~/megauni/templates/en-us/html/Clubs_read_fights.rb
# SASS  ~/megauni/templates/en-us/css/Clubs_read_fights.sass
# NAME  Clubs_read_fights

require 'views/extensions/Base_Club'

class Clubs_read_fights < Base_View

  include Views::Base_Club

  def title 
    "#{club_title} Fights"
  end

  def passions
    compile_and_cache( 'messages.passions' , app.the.passions )
  end
  
end # === Clubs_read_fights 
