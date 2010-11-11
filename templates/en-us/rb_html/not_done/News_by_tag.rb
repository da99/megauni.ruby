save_to('title') { 
  if app_vars[:news_tag].nil?
    "Tag not found."
  else
    app_vars[:news_tag]
  end
}


partial('__nav_bar')


div.content! { 
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
  
  h2( '{{title}}' )
  
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
        span.published_at post.published_at.strftime('%b  %d, %Y')
        a.permalink('PermaLink', :href=>"/news/#{post.data._id}/")
       }
       h4 post.data.title
       div.body { 
         the_app.news_to_html post, :body
       }
      }
    end
  end
  
} # === div.content!



