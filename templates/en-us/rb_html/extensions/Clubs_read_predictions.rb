# MAB     ~/megauni/templates/en-us/html/Clubs_read_predictions.rb
# VIEW    ~/megauni/views/Clubs_read_predictions.rb
# SASS    ~/megauni/templates/en-us/css/Clubs_read_predictions.sass
# NAME    Clubs_read_predictions
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module Ruby_To_Html::Actions::Clubs_read_predictions

  module STRANGER
  end # ======== module

  module MEMBER
  end # ======== module

  module INSIDER
    
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

  module OWNER
    
    include INSIDER

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

  def messages_list
    'predictions'
  end

  def about
    super( '* * *', ' - - - ')
  end
  
  def publisher_guide
    p 'Nothing published so far.'
  end

end # === module Ruby_To_Html::Actions::Clubs_read_predictions
      
