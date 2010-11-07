# MAB   /home/da01tv/MyLife/apps/megauni/templates/en-us/html/Clubs_by_old_id.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/en-us/css/Clubs_by_old_id.sass
# NAME  Clubs_by_old_id

class Clubs_by_old_id < Base_View

  def title 
    app.the.club
  end

  def css_file
    "/stylesheets/#{lang}/Topic_#{app.the.club}.css"
  end
  
end # === Clubs_by_old_id 
