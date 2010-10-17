# MAB   ~/megauni/templates/en-us/mab/Clubs_club_search.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_club_search.sass
# NAME  Clubs_club_search

class Clubs_club_search < Base_View

  def title 
    "Club not found: #{club_filename}"
  end

  def clubs
    @cache_clubs ||=  ( egg_timers_as_clubs + compile_clubs(Club.all) + old_clubs ) 
  end

  def club_filename
    app.the.filename
  end
  
end # === Clubs_club_search 
