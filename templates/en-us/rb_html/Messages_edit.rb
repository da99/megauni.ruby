# VIEW views/Messages_edit.rb
# SASS ~/megauni/templates/en-us/css/Messages_edit.sass
# NAME Messages_edit

div.content! { 
  
  form.form_messages_update!( :action=>"{{mess_href}}", :method=>'post' ) do
  
    fieldset_hidden {
      _method_put
      input_hidden 'editor_id', '{{editor_id}}'
    }

    as 'mess_data' do
      fieldset {
        label 'Title:'
        input_text 'title', '{{title}}'
      }

      fieldset {
        label 'Body:'
        textarea '{{body}}', :name=>'body'
      }
    end

    div.buttons {
      button 'Save'
    }

  end

  a('Cancel and go back to message.', :href=>"{{mess_href}}")
  
} # === div.content!

partial('__nav_bar')

