# MAB     ~/megauni/templates/en-us/html/Clubs_read_magazine.rb
# VIEW    ~/megauni/views/Clubs_read_magazine.rb
# SASS    ~/megauni/templates/en-us/css/Clubs_read_magazine.sass
# NAME    Clubs_read_magazine
# CONTROL models/Club.rb
# MODEL   controls/Club.rb

module MAB_Clubs_read_magazine_STRANGER
end

module MAB_Clubs_read_magazine_MEMBER
end

module MAB_Clubs_read_magazine_INSIDER
  def publisher_guide
      guide( 'Stuff you can do:' ) {
        ul {
          li 'Write a story.'
        }
      }
  end
end

module MAB_Clubs_read_magazine_OWNER
  def publisher_guide
      guide( 'Stuff you can do:' ) {
        ul {
          li 'Write a story.'
          li 'Review a restaurant.'
          li 'Write about a family reunion.'
        }
      }
  end
end

module MAB_Clubs_read_magazine
  
  def messages_list
    'storys'
  end
  
  def publisher_guide
    p 'Nothing posted yet.'
  end

  def post_message
      super {
        css_class'col'
        title  'Publish a new story:'
        input_title 
        hidden_input(
          :message_model => 'mag_story',
          :club_filename => '{{club_filename}}',
          :privacy       => 'public'
        )
      }
  end

  def about
    super('* * *', '- - -')
  end

end # === module MAB_Clubs_read_magazine
      
