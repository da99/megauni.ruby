# MAB     ~/megauni/templates/en-us/html/Clubs_read_fights.rb
# VIEW    ~/megauni/views/Clubs_read_fights.rb
# SASS    ~/megauni/templates/en-us/css/Clubs_read_fights.sass
# NAME    Clubs_read_fights
# CONTROL models/Club.rb
# MODEL   controls/Club.rb
# 

module Ruby_To_Html::Actions::Clubs_read_fights

  module STRANGER
  end

  module MEMBER
  end

  module INSIDER
    def publisher_guide
      guide('Stuff you can do:') {
        p %~
          Express negative feelings. Try to use
          polite profanity, like meathead instead of 
          doo-doo head.
        ~
      }
    end
  end

  module OWNER
    def publisher_guide
      guide('Stuff you can do:') {
        p %~
          You can start fights or let others 
          start fightss with you.
        ~
      }
    end
  end
  
  def messages_list
    'passions'
  end

  def about
    super('* * *', ' - - - ')
  end
  
  def publisher_guide
    p 'Nothing posted yet.'
  end

  def post_message
    super {
      css_class  'col'
      title      'Publish a new:'
      models     %w{fight complaint debate}
      input_title 
      hidden_input(
        :club_filename => '{{club_filename}}',
        :privacy       => 'public'
      )
    }
  end

end # === module
