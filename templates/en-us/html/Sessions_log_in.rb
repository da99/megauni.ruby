# ~/megauni/views/Sessions_log_in.rb
# ~/megauni/templates/en-us/css/Sessions_log_in.sass
# Session_Control_log_in

partial('__nav_bar')

div.the_form! { 
  
  # ================= div.flash_msg =============================

    h2 'Log-in'
    
    form.log_in_form!( :action=>"/log-in/", :method=>"post" ) {
    
      fieldset {
        label 'Username'
        input.text( :id=>"member_username", :name=>"username", :type=>"text", :value=>'' )
      }
      
      fieldset {
        label 'Password'
        input.text( :id=>"member_password", :name=>"password", :type=>"password", :value=>'' )
      }
      
      div.buttons {
        button.create 'Log-in', :onclick=>"document.getElementById('log_in_form').submit(); return false;" 
      }
      
    } # === form.log_in_form!

    h2 "Forgot your password?"

    form.reset_password_form!(:action=>'/reset-password/', :method=>"post") {
      fieldset {
        label 'Email'
        input.text( :id=>"member_email", :name=>"email", :type=>"text", :value=>'')
      }
      div.buttons {
        button.create 'Get My Password', :onclick=>"document.getElementById('reset_password_form!').submit(); return false;" 
      }
    }

} # === div.the_form!


