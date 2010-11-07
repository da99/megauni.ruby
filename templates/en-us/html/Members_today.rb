# VIEW views/Members_today.rb
# SASS templates/en-us/css/Members_today.sass
# NAME Member_Control_today

div.stream! {
  
  show_if 'no_stream?' do
    p {
      span "On {{site_title}}, you can join "
      a(" different universes", :href=>'/uni/')
      span " or post messages to your "
      a( "own universe", :href=>"{{my_club_href}}" )
      span ' . '
    }
  end

  show_if 'stream?' do  
    h4 'The latest from clubs you follow:'
    loop_messages 'stream'  
  end
  
} # === div.stream!

partial('__nav_bar')

