# MAB   ~/megauni/templates/en-us/html/Clubs_read_thanks.rb
# SASS  ~/megauni/templates/en-us/css/Clubs_read_thanks.sass
# NAME  Clubs_read_thanks

require 'views/extensions/Base_Club'

class Clubs_read_thanks < Base_View
  
  include Views::Base_Club

  def title 
    "Thank you for #{club_title}"
  end

  def thanks
    @thanks ||= compile_messages(app.the.thanks )
  end
  
end # === Clubs_read_thanks 
