# MAB   ~/megauni/templates/en-us/mab/Clubs_read_news.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_news.sass
# NAME  Clubs_read_news

require 'views/extensions/Base_Club'

class Clubs_read_news < Base_View

  include Views::Base_Club

  def title 
    return "News: #{club_title}" unless club.is_a?(Life)
    "#{club_filename}'s Important News"
  end
  
  def news
    @news ||= compile_messages(app.the.news )
  end
  
end # === Clubs_read_news 
