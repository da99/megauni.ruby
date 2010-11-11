save_to('title') { the_app.doc.data.title }




div.content! { 
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
  

  div.news_post {
   
   div.info {
    span.published_at the_app.doc.published_at.strftime('%b  %d, %Y')
   }
   h4 the_app.doc.data.title
   div.body { 
     the_app.news_to_html the_app.doc, :body
   }

   if !the_app.doc.data.tags.empty?
     div.tags {
      if the_app.doc.updator?(the_app.current_member)
        a('Edit', :href=>"#{the_app.request.path_info}edit/")
      end
      p.title 'Tags:'
      ul {
        the_app.doc.data.tags.each do |tag|
          li {
            a(tag, :href=>"/news/by_tag/#{tag}/")
          }
        end
      }
      
     }
   end
  }
  
} # === div.content!


partial('__nav_bar')

