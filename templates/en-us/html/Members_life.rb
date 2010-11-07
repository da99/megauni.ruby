# VIEW views/Members_life.rb
# SASS ~/megauni/templates/en-us/css/Members_life.sass
# NAME Members_life
# CONTROL controls/Members
# MODEL   models/Member

div.col.navigate! {
  
  h3 '{{title}}'
  
  life_club_nav_bar(__FILE__)

  div.club_messages! do
    
    if_empty('stream'){
      div.empty_msg 'No messages have been posted.'
    }
    
    loop_messages 'stream'
    
  end
  
} # div.navigate!


div {
  h4 "Things to do:"
  ul {
    li "Create a universe for your friend."
    li "Post on your friend's universes?"
    li "What did you do today?"
    li "Discover other universes."
    li "Watch this video."
  }
}

