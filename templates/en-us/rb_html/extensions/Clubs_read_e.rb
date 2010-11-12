# MAB     ~/megauni/templates/en-us/html/Clubs_read_e.rb
# VIEW    ~/megauni/views/Clubs_read_e.rb
# SASS    ~/megauni/templates/en-us/css/Clubs_read_e.sass
# NAME    Clubs_read_e
# CONTROL models/Club.rb
# MODEL   controls/Club.rb
# 

module Ruby_To_Html::Actions::Clubs_read_e
  
  module STRANGER
  end # === module


  module MEMBER
  end # === module

  module INSIDER
  end # === module

  module OWNER
    def about
      about_section(
        'About this encyclopedia', 
        'Write important information worth remembering here. Use it as a referece for your {{club_type}}.'
      )
    end

    def publisher_guide
      p 'publisher guide goes here'
    end
  end # === module

  def messages_list
    [ 
      { 'quotes' => 'Quotations'},
      { 'chapters' => 'Chapters' }
    ]
  end

  def insider_publisher_guider
    guide('Stuff you can do:') {
      ul {
        li 'Write a story about this person.'
        li 'Post a quotation about this person.'
      }
    }
  end

  def owner_publisher_guide
    guide('Stuff you can do:') {
      ul {
        li 'Write a story. '
        li 'Post a quotation.'
      }
    }
  end

  def post_message
    super {
      css_class  'col'
      title  'Publish a new:'
      input_title 
      models  %w{e_quote e_chapter}
      hidden_input(
        :club_filename => '{{club_filename}}',
        :privacy       => 'public'
      )
    }
  end
  
  def about
    super('* * *', '----')
  end

  def publisher_guide
    p 'No posts yet.'
  end

end # === module
