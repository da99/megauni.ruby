# MAB     ~/megauni/templates/en-us/html/Clubs_read_shop.rb
# VIEW    ~/megauni/views/Clubs_read_shop.rb
# SASS    ~/megauni/templates/en-us/css/Clubs_read_shop.sass
# NAME    Clubs_read_shop
# CONTROL models/Club.rb
# MODEL   controls/Club.rb


module Ruby_To_Html::Actions::Clubs_read_shop
  
  module STRANGER
  end # === module 

  module MEMBER
  end # === module 

  module INSIDER
    
    def publisher_guide
        guide( 'Stuff you can do here:' ) {
          p %~
            You post your favorite stuff to buy.
          Tell people: 
          ~
          ul {
            li 'where you bought it.'
            li 'how much it cost you.'
            li 'why others should buy it too.'
          }
        }
    end

    def post_message
      super {
        css_class  'col'
        title  'Recommend a product:'
        input_title 
        hidden_input(
          :message_model => 'buy',
          :club_filename => '{{club_filename}}',
          :privacy       => 'public'
        )
      }
    end
    
  end # === module 

  module OWNER
    include INSIDER
  end # === module 
  
  def messages_list
    'buys'
  end

  def publisher_guide
    p 'Nothing posted yet.'
  end

  def about
    super('* * *' , '- - -')
  end

end # === module Ruby_To_Html::Actions::Clubs_read_shop
      
