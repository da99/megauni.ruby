# MAB   /home/da01tv/MyLife/apps/megauni/templates/en-us/html/Clubs_read_e.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/en-us/css/Clubs_read_e.sass
# NAME  Clubs_read_e

class Clubs_read_e < Base_View

  def title 
    "Encyclopedia: #{club.data.title}"
  end

  def club
    app.the.club
  end
  
end # === Clubs_read_e 
