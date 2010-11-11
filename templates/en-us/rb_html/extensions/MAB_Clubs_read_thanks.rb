# MAB     ~/megauni/templates/en-us/html/Clubs_read_thanks.rb
# VIEW    ~/megauni/views/Clubs_read_thanks.rb
# SASS    ~/megauni/templates/en-us/css/Clubs_read_thanks.sass
# NAME    Clubs_read_thanks
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module MAB_Clubs_read_thanks_STRANGER
end

module MAB_Clubs_read_thanks_MEMBER
end

module MAB_Clubs_read_thanks_INSIDER
  
  def post_message
    super {
      css_class  'col'
      title  'Post a thank you:'
      hidden_input(
        :message_model => 'thank',
        :club_filename => '{{club_filename}}',
        :privacy       => 'public'
      )
    }
  end
  
  def publisher_guide 
    guide( 'Stuff you can do here:' ) {
      p %~
      Give thanks if this {{club_type}}
      has helped you.
          ~
    }
  end
  
end

module MAB_Clubs_read_thanks_OWNER
  
  include MAB_Clubs_read_thanks_INSIDER

  def publisher_guide 
    guide( 'Stuff you can do here:' ) {
      p %~
         This is where people can post 
          their appreciation.
          ~
    }
  end
end

module MAB_Clubs_read_thanks
  
  def messages_list
    'thanks'
  end

  def publisher_guide
    p 'Nothing posted yet.'
  end

  def about
    super ' * * *', ' - - -'
  end

end # === module MAB_Clubs_read_thanks
      
