# VIEW views/Members_life_e.rb
# SASS ~/megauni/templates/en-us/css/Members_life_e.sass
# NAME Members_life_e

div.col.navigate! {
  
  h3 '{{title}}'
  
  life_club_nav_bar(__FILE__)

  div.club_messages! do
    
    show_if('no_facts?'){
      div.empty_msg 'Nothing has been posted yet.'
    }
    
    loop_messages 'facts'
    
  end
  
} # div.navigate!

div.col.intro! {

  show_if 'logged_in?' do
    
    post_message {
      title  'Post a new section:'
      input_title  
      hidden_input(
        :message_model => 'fact',
        :privacy       => 'public',
        :target_ids    => '{{owner_username_id}}'
      )
    }
    
  end # logged_in?
  
} # === div.intro!


