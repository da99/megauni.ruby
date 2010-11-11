# VIEW views/Members_life_qa.rb
# SASS ~/megauni/templates/en-us/css/Members_life_qa.sass
# NAME Members_life_qa

div.col.navigate! {
  
  h3 '{{title}}'
  
  life_club_nav_bar(__FILE__)

  div.club_messages! do
    
    show_if('no_questions?'){
      div.empty_msg 'No questions have been asked.'
    }
    
    loop_messages 'questions'
    
  end

} # div.navigate!



div.col.intro! {

  show_if 'logged_in?' do
    
    post_message {
      title 'Ask a question:'
      hidden_input(
        :message_model => 'question',
        :privacy       => 'public',
        :target_ids    => '{{owner_username_id}}'
      )
    }
    
  end # logged_in?

} # div.intro!

