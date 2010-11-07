# VIEW views/Members_life_status.rb
# SASS ~/megauni/templates/en-us/css/Members_life_status.sass
# NAME Members_life_status

div.col.navigate! {
  
  h3 '{{title}}' 
  
  life_club_nav_bar(__FILE__)

  div.club_messages! do
    
    show_if('no_statuses?'){
      div.empty_msg 'Nothing has been posted yet.'
    }
    
    loop_messages 'statuses'
    
  end

} # div.navigate!


div.col.intro! {
  
  show_if 'logged_in?' do
    
    post_message {
      title 'What are you doing?'
      hidden_input(
        :message_model => 'status', 
        :privacy       => 'public',
        :target_ids    => '{{owner_username_id}}'
      )
    }
    
  end # logged_in?

} # div.intro!
