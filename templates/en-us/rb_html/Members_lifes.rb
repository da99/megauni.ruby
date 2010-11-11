# VIEW    views/Members_lifes.rb
# SASS    templates/en-us/css/Members_lifes.sass
# NAME    Members_lifes
# CONTROL models/Member.rb
# MODEL   controls/Member.rb

member_nav_bar __FILE__

div.col.lifes! {

  h4 'Your lifes:'

  loop 'lifes' do
    a!('username', 'href')
  end

} # === div.messages!


div.col.create! { 
  
  # ================= div.flash_msg =============================
  

  h3 'Add another username.'
  
  form.form_username_create!(:action=>"/member/", :method=>"post") {
    
    fieldset_hidden {
      _method_put
    }

    fieldset {
      label 'New Username'
      input.text( :id=>"username_name", :name=>"add_username", :type=>"text", :value=>'{{ session_form_username }}' )
    }

    div.buttons {
      button.create 'Save'
    }

  } # === form.create_account_form!

} # === div.create!

div.col.kill_me! {
  
  p %@
    Would you like to delete your {{site_name}} account? 
  @
  
  p %@
    When I say "delete", I mean it. It will be as if you never existed.
  @

  p %@ Your usernames will also be deleted. ALL of them.@

  p {
    strong 'Remember:'
    span 'Delete ALL your clubs first. All else they will remain.'
  }

  form.delete_account_form!(:method=>'post', :action=>"/delete-account-forever-and-ever/") {
    fieldset_hidden {
      _method_delete
    }
    p { strong "Are you really, really sure? (There is no undo.)" }
    div.buttons {
      button("Yes!", :onclick=>"if(confirm('Are you really, really sure?')) { document.getElementById('delete_account_form').submit(); }; return false;")
    }
  } # form

} # div.kill_me!


