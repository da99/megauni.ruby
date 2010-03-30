# VIEW views/Messages_by_id.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/English/sass/Messages_by_id.sass
# NAME Messages_by_id

div.content! { 
  
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
  
  div.heart_link.news_post {
   
   div.info {
    span.published_at '{{published_at}}'
   }

   mustache 'message_data' do
     h4 '{{title}}'
     div.body { '{{{compiled_body}}}' }
   end
  }
  
  div.news_post.archives! {
    h4 'Archives:'
    div.body {
    
      a('See all.', :href=>'/clubs/hearts/')
      
    }
  }
} # === div.content!

partial('__nav_bar')

