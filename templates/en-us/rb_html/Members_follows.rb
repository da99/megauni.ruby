# VIEW ~/megauni/views/Members_follows.rb
# SASS ~/megauni/templates/en-us/css/Members_follows.sass
# NAME Members_follows
# CONTROL models/Member.rb
# MODEL   controls/Member.rb

member_nav_bar __FILE__

div.col {
  show_if('no_stream?') {
    div('You have not subscribed to anyone\'s life.')
  }
  show_if 'stream?' do  
    h4 'The latest from your subscriptions:'
    loop 'stream' do
      div.message do
        div.body( '{{{compiled_body}}}' )
        div.permalink {
          a('Permalink', :href=>"{{href}}")
        }
      end
    end
  end
} # === div.stream!
  
div_filter_options 'follows'
