# MAB     ~/megauni/templates/en-us/html/Clubs_read_news.rb
# VIEW    ~/megauni/views/Clubs_read_news.rb
# SASS    ~/megauni/templates/en-us/css/Clubs_read_news.sass
# NAME    Clubs_read_news
# CONTROL models/Club.rb
# MODEL   controls/Club.rb


module Ruby_To_Html::Actions::Clubs_read_news
  
  module STRANGER
  end

  module MEMBER
  end

  module INSIDER
  end

  module OWNER
    def publisher_guide
          guide( 'Stuff you can do here:' ) {
            p %~
              Post only important news. 
            Examples:
            ~
            ul {
              li 'Your plane landed in Dallas.'
              li 'You got a job demotion.'
              li 'You broke up with your dog walker.'
              li 'You got arrested... again.'
            }
          }
    end
  end

  
  def messages_list
    'news'
  end

  def post_message
    super {
      css_class  'col'
      title  'Post news:'
      input_title 
      hidden_input(
        :message_model => 'news', 
        :club_filename => '{{club_filename}}',
        :privacy       => 'public'
      )
    }
  end

  def about
    super('* * *', ' - - - ')
  end
  
  def publisher_guide
    p "No news posted yet."
  end

end # === module Ruby_To_Html::Actions::Clubs_read_news
      
