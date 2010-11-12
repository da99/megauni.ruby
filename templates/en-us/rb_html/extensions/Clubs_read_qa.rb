# MAB     ~/megauni/templates/en-us/html/Clubs_read_qa.rb
# VIEW    ~/megauni/views/Clubs_read_qa.rb
# SASS    ~/megauni/templates/en-us/css/Clubs_read_qa.sass
# NAME    Clubs_read_qa
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module Ruby_To_Html::Actions::Clubs_read_qa

  module STRANGER
  end # === module 

  module MEMBER
  end # === module 

  module INSIDER
    
    def post_message
      super {
        css_class  'col'
        title  'Publish a new:'
        models  %w{question plea}
        input_title
        hidden_input(
          :club_filename => '{{club_filename}}',
          :privacy       => 'public'
        )
      }
    end
    
    def publisher_guide
      guide('Stuff you can do here:') {
        p %~
          Ask questions.
        ~
      } # === guide
    end

  end # === module 

  module OWNER
    def publisher_guide
      owner {
        guide('Stuff you can do here:') {
          p %~
            Ask questions and answer them
          ~
        } # === guide
      }
    end

  end # === module 
  
  def messages_list
    'questions'
  end

  def publisher_guide
    p 'No questions have been asked yet.'
  end

  def about
    super('* * *', ' - - - ')
  end
  
end # === module Ruby_To_Html::Actions::Clubs_read_qa
      
