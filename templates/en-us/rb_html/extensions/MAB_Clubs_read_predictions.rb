# MAB     ~/megauni/templates/en-us/html/Clubs_read_predictions.rb
# VIEW    ~/megauni/views/Clubs_read_predictions.rb
# SASS    ~/megauni/templates/en-us/css/Clubs_read_predictions.sass
# NAME    Clubs_read_predictions
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module MAB_Clubs_read_predictions_STRANGER
end # ======== module

module MAB_Clubs_read_predictions_MEMBER
end # ======== module

module MAB_Clubs_read_predictions_INSIDER
  
  def post_message

          super {
            css_class  'col'
            title  'Post a prediction:'
            hidden_input(
              :message_model => 'prediction', 
              :club_filename => '{{club_filename}}',
              :privacy       => 'public'
            )
          }
        
  end
  
  def publisher_guide
        guide( 'Stuff you can do here:' ) {
          p %~
            Oublish your thoughts
          on what will happen in the future.
          ~
        }
  end
  
end # ======== module

module MAB_Clubs_read_predictions_OWNER
  
  include MAB_Clubs_read_predictions_INSIDER

  def publisher_guide
        guide( 'Stuff you can do here:' ) {
          p %~
            This is where you can publish your thoughts
          on what will happen in the future.  When
          you are right, you can yell, "I told you so!"
          ~
        }
  end
  
end # ======== module

module MAB_Clubs_read_predictions

  def messages_list
    'predictions'
  end

  def about
    super( '* * *', ' - - - ')
  end
  
  def publisher_guide
    p 'Nothing published so far.'
  end

end # === module MAB_Clubs_read_predictions
      
