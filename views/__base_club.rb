# MAB   /home/da01tv/MyLife/apps/megauni/templates/en-us/mab/Clubs_read_e.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME  Clubs_read_e

class Clubs_read_e < Base_View

  def title 
    "Encyclopedia: #{club.data.title}"
  end

  def club
    app.env['results.club']
  end
  
end # === Clubs_read_e 
