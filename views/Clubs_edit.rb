# MAB   ~/megauni/templates/en-us/html/Clubs_edit.rb
# SASS  ~/megauni/templates/en-us/css/Clubs_edit.sass
# NAME  Clubs_edit

require 'views/__Base_View_Club'

class Clubs_edit < Base_View

  include Base_View_Club
  
  def title 
    "Edit: #{club_title}"
  end
  
end # === Clubs_edit 
