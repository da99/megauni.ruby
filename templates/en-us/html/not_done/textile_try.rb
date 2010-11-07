save_to(:title) { 'Try Out Textile' }

div.content! {
  div.writer! {
    form.form_writer!(:action=>the_app.request.fullpath, :method=>'post') {
      fieldset {
        label "Your Content:"
        textarea( the_app.clean_room[:content] || '', :name=>'content', :id=>'textile_content')
      }

      div.buttons {
        button.submit 'Process' , :onclick=>"document.getElementById('form_writer').submit(); return false;"
      }
    } # === form
  } # === div.writer!

  div.printer! {
    div.html app_vars[:html_output] || "No content yet."
    
    div.browser {
      app_vars[:html_output] || "No content yet."
    }
  }
} # === div.content!


partial('__nav_bar')


