save_to('title') { 'Admin' }
save_to('javascripts') { 'default' }
save_to('loading') { 'default' }


div.nav_bar! {
  h2 'My Work'

  ul {  
    li { a('Home', :href=>'/') }
    
    show_if 'logged_in?' do
      li { a('Logout', :href=>'/log-out/') }
    end

    li { a('Get Help', :href=>'#help') }
  } # ul

} # nav_bar!



# =================== These are tabs to show create forms. 
ul.create_tabs! {
  
  li.selected {
    a( 'Locations', :href=>"#create_location", :onclick=>"Swiss.tab.select(this); return false;" )
  }

} # ul.create_tabs!



# ================== These are the forms to create new model instances.
div.form_holder.tab_selected.create_slice_location! {



  form(:action=>"/slice_location/create", :method=>:post, :name=>'form_create_slice_location') {
    
    h3 'Create a location'
    
    fieldset.input_text.title {
      label 'Title'
      input(:name=>'title', :type=>'text', :value=>'' )
    }

    fieldset.textarea.description {
      label {
        span 'Tagline or Short Description'
        span.sub '(optional)'
      }
      textarea('', :name=>'description')
    } 

    div.status_msg ''

    div.buttons {
      a.save('Save', :href=>'#save_slice_location', :onclick=>"SliceLocation.create(this); return false;")
    }
    
  } # form

} # div.form_holder


div.form_holder.tab_unselected.update_account! {

  
  form.update_account(:name=>'form_update_settings', :action=>"/work/update_account", :method=>'post') {
    h3 'Update Email'  
    fieldset.input_text.email {
      label 'Update Email'
      input(:name=>'email', :type=>'text', :value=>'')
    }

    div.status_msg  ''

    div.buttons {
      a.update('Update', :href=>'#update_my_settings', :onclick=>"Member.update_account(this); return false;")
    }

  } # form

  form.update_password(:name=>'form_update_password', :action=>'/work/update_password', :method=>'post') {
    h3 'Update Password'


    fieldset.input_text.password {
      label 'Old Password'
      input(:name=>'password', :type=>'password', :value=>'')
    }

    fieldset.input_text.password {
      label 'New Password'
      input(:name=>'new_password', :type=>'password', :value=>'')
    }

    fieldset.input_text.password {
      label 'Confirm New Password'
      input(:name=>'confirm_password', :type=>'password', :value=>'')
    }

    div.status_msg  ''

    div.buttons {
      a.update('Update Password', :href=>'#update_password', :onclick=>"Member.update_password(this); return false;")
    }

  } # form
} # div.form_holder

