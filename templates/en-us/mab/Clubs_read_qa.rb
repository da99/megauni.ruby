# VIEW ~/megauni/views/Clubs_read_qa.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_qa.sass
# NAME Clubs_read_qa

div.col.intro! {
  h3 '{{title}}' 

  show_if 'logged_in?' do
    
    form_message_create(
      :models => %w{question complaint plea},
      :hidden_input => {
        :club_filename => '{{club_filename}}',
        :privacy       => 'public'
      }
    )
    
  end # logged_in?

} # div.intro!

div.col.navigate! {
  
  club_nav_bar(__FILE__)

  div.club_messages! do
    
    show_if('no_questions?'){
      div.empty_msg 'No questions have been asked.'
    }
    
    loop_messages 'questions'
    
  end

} # div.navigate!
