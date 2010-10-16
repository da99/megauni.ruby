# MAB   ~/megauni/templates/en-us/mab/Clubs_list.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_list.sass
# NAME  Clubs_list

class Clubs_list < Base_View

  def title 
    'Full list of clubs.'
  end

  def clubs
    compile_and_cache( 'clubs' , app.the.clubs )
  end

  def other_clubs
    @cache_clubs_other ||= (clubs - your_clubs)
  end

end # === Clubs_list 
