
# VIEW views/Clubs_by_id.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Clubs_by_id.sass
# NAME Clubs_by_id

div.content! { 
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
  

  div.news_post.label_archives! {
    h4 'Archives By Label'
    div.body {
    
      ul {
        loop 'public_labels' do 
          li {
            a( '{{filename}}', :href=>"/clubs/hearts/by_label/{{filename}}/")
          }
        end
      } # === ul
          
    }
  }

  div.news_post.date_archives! {
    h4 'Archives By Date'
    div.body {
    
      ul {
        loop 'months' do
          li {
            a( '{{text}}', :href=>"{{href}}" )
          }
        end
      } # === ul
      
    }
  }
  
  
} # === div.content!


partial('__nav_bar')

