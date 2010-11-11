# MODULE templates/en-us/html/extensions/MAB_Clubs_read_magazine.rb
# VIEW ~/megauni/views/Clubs_read_magazine.rb
# SASS ~/megauni/templates/en-us/css/Clubs_read_magazine.sass
# NAME Clubs_read_magazine

club_nav_bar(__FILE__)

pretension!

div.substance! do
    
  messages! {
    messages_or_guide
  }
  
  publish! {
    
    stranger {
      about
    }

    insider_or_owner {
      about
      post_message
    }
    
  } # === publish!

end # div.outer_shell!
