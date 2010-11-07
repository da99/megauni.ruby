# MAB   ~/megauni/templates/en-us/html/Clubs_read_shop.rb
# SASS  ~/megauni/templates/en-us/css/Clubs_read_shop.sass
# NAME  Clubs_read_shop

require 'views/extensions/Base_Club'

class Clubs_read_shop < Base_View

  include Views::Base_Club

  def title 
    return "Shop: #{club_title}" unless club.is_a?(Life)
    "#{club_filename}'s Favorite Stuff"
  end

  def buys
    @buys ||= compile_messages( app.the.buys  )
  end
  
end # === Clubs_read_shop 
