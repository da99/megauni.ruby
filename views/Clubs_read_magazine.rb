# MAB   ~/megauni/templates/en-us/html/Clubs_read_magazine.rb
# SASS  ~/megauni/templates/en-us/css/Clubs_read_magazine.sass
# NAME  Clubs_read_magazine

require 'views/extensions/Base_Club'

class Clubs_read_magazine < Base_View

  include Views::Base_Club

  def title 
    "Magazine: #{club_title}"
  end

  def storys
    @storys ||= compile_messages(app.the.magazine )
  end
  
end # === Clubs_read_magazine 
