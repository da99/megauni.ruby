# VIEW views/Clubs_edit.rb
# SASS ~/megauni/templates/en-us/css/Clubs_edit.sass
# NAME Clubs_edit

div.col.the_form! {

  form_post('edit_form', '{{club_href}}') {
  
    fieldset_hidden {  
      _method_put
    }

    fieldset 'Filename:', '{{club_filename}}'
    fieldset 'Title:', '{{club_title}}'
    fieldset! 'Teaser:', '{{club_teaser}}'

    div.buttons {
      button_update 
    }

  } # === form

} # === div.form!

partial('__nav_bar')

