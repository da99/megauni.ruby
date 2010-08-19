# VIEW views/Clubs_read_shop.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_read_shop.sass
# NAME Clubs_read_shop

partial '__club_title'

club_nav_bar(__FILE__)

div.outer_shell! do
  div.inner_shell! do
    
    div.club_body! {

      show_if 'logged_in?' do
        
        div_guide!( 'Stuff you can do here:' ) {
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

          post_message {
            css_class  'col'
            title  'Recommend a product:'
            input_title 
            hidden_input(
              :message_model => 'buy',
              :club_filename => '{{club_filename}}',
              :privacy       => 'public'
            )
          }
        
      end # logged_in?


      div.col.club_messages! do
        
        loop_messages_with_opening(
          'buys',
          'Latest Buys:',
          'Nothing has been posted yet.'
        )

      end
      
    } # div.navigate!

  end # div.inner_shell!
end # div.outer_shell!
