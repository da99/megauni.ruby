# MODULE templates/en-us/html/extensions/MAB_Clubs_read_shop.rb
# VIEW views/Clubs_read_shop.rb
# SASS ~/megauni/templates/en-us/css/Clubs_read_shop.sass
# NAME Clubs_read_shop

club_nav_bar(__FILE__)

pretension!

div.substance! {
  
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

} # === div.substance!
