# VIEW views/Members_life_shop.rb
# SASS ~/megauni/templates/en-us/css/Members_life_shop.sass
# NAME Members_life_shop

div.col.navigate! {
  
  h3 '{{title}}'
  
  life_club_nav_bar(__FILE__)

  div.club_messages! do
    
    show_if('no_buys?'){
      div.empty_msg 'Nothing has been posted.'
    }
    
    loop_messages 'buys'
    
  end

} # div.navigate!



div.col.intro! {

  show_if 'logged_in?' do
    
    post_message {
      title 'Bought something? Post it here:'
      hidden_input(
        :message_model => 'buy',
        :privacy       => 'public'
      )
    }
    
  end # logged_in?

} # div.intro!

