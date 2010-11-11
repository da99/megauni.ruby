save_to('title') { 
  "Posts for: #{app_vars[:date].strftime('%B %Y')}"
}


partial('__nav_bar')


div.content! { 
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
  

  h2  app_vars[:date].strftime('%B %Y') 
  
  if app_vars[:news].empty?
    div.heart_link {
      h4 '---'
      div.body {
        'No heart links found.'
      }
    }
  else
    app_vars[:news].each do |post|
      div.heart_link {
       
       div.info {
        span.published_at post[:published_at].strftime('%b  %d, %Y')
        a.permalink('PermaLink', :href=>"/news/#{post[:id]}/")
       }
       h4 post[:title]
       div.body { 
         the_app.news_to_html( post, :body ) 
       }
      }
    end
  end
  
} # === div.content!



