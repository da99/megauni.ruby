save_to('title') { 'Create News' }

partial('__nav_bar')


div.content!  { 
  
  h3 'Create News'


  form.form_new_news!(:action=>'/news/', :method=>'post') {
  
    fieldset {
      label 'Title'
      input.text( :id=>"news_title", :name=>"title", :type=>"text", :value=>'' )
    }

    fieldset {
      label 'Teaser'
      textarea('', :id=>"news_teaser", :name=>"teaser")
    }

    fieldset {
      label 'body'
      textarea('', :id=>"news_body", :name=>"body")      
    }

    fieldset {
      label 'Tags'
      the_app.news_tags.each do |t|
        div.box { 
          checkbox false, :name=>'tags[]', :value=>t[:id]
          span t[:filename]
        }
      end
    }

    div.buttons {
      button.create 'Create News', :onclick=>"document.getElementById('form_news_new').submit(); return false;" 
    }


  } # === form
} # === div.content!
