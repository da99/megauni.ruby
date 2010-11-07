# MAB     ~/megauni/templates/en-us/html/Clubs_read_qa.rb
# VIEW    ~/megauni/views/Clubs_read_qa.rb
# SASS    ~/megauni/templates/en-us/css/Clubs_read_qa.sass
# NAME    Clubs_read_qa
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module MAB_Clubs_read_qa_STRANGER
end # === module 

module MAB_Clubs_read_qa_MEMBER
end # === module 

module MAB_Clubs_read_qa_INSIDER
  
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

module MAB_Clubs_read_qa_OWNER
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

module MAB_Clubs_read_qa
  
  def messages_list
    'questions'
  end

  def publisher_guide
    p 'No questions have been asked yet.'
  end

  def about
    super('* * *', ' - - - ')
  end
  
end # === module MAB_Clubs_read_qa
      
