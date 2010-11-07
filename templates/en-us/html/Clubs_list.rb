# VIEW views/Clubs_list.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/css/Clubs_list.sass
# NAME Clubs_list

show_if 'your_clubs?' do
  div.clubs.my_clubs! {
    h4 'Your Clubs:'
    loop 'your_clubs' do 
      div.club {
        h4 {
          a '{{title}}', :href=>'{{href}}'
        }
        div.teaser '{{teaser}}'
      }
    end
  }
end

show_if('other_clubs?') {
  div.clubs.clubs! do
    h4 'Clubs:'
    loop 'other_clubs' do 
      div.club {
        div {
          a '{{title}}', :href=>'{{href}}'
        }
        div.teaser '{{teaser}}'
      }
    end
  end
} 
  


partial('__mini_nav_bar')
