# ~/megauni/views/Members_create_account.rb
# ~/megauni/templates/en-us/sass/Members_create_account.sass
# Members_create_account 

partial('__nav_bar')

div.the_form! { 
  
  # ================= div.flash_msg =============================


  h2 'Create a New Account'
  
  form.form_member_create!(:action=>"/member/", :method=>"post") {
    
    fieldset {
      label 'Username'
      input.text( :id=>"username_name", :name=>"add_username", :type=>"text", :value=>'{{ session_form_username }}' )
    }
    
    fieldset {
      label 'Password'
      input.text( :id=>"password", :name=>"password", :type=>"password", :value=>'' )
    }
    
    fieldset {
      label { span 'Confirm Password'  }
      input.text( :id=>"confirm_password", :name=>"confirm_password", :type=>"password", :value=>'' )
    }
    
    fieldset {
      label 'Language'
      select :name=>'lang' do
        loop 'languages' do
          show_if 'selected?' do
            option '{{name}}', :value=>'filename', :selected=>'selected'
          end
          show_if 'not_selected?' do
            option '{{name}}', :value=>'filename'
          end
        end
      end
    }

    div.buttons {
      button.create 'Create My New Account', :onclick=>"document.getElementById('create_account_form').submit(); return false;" 
    }

  } # === form.create_account_form!

  
} # === div.content!


