# MODULE templates/en-us/html/extensions/MAB_Clubs_read_fights.rb
# VIEW ~/megauni/views/Clubs_read_fights.rb
# SASS ~/megauni/templates/en-us/css/Clubs_read_fights.sass
# NAME Clubs_read_fights

club_nav_bar(__FILE__)

pretension!

div.substance! do
    
    messages! {
      everybody {
        messages_or_guide
      }
    }
    
    publish! {
      
      everybody { about }
      
      insider_or_owner {
        post_message
      }
      
    } # === publish!

end # div.substance!
