# VIEW views/Members_change_password.rb
# SASS ~/megauni/templates/en-us/css/Members_change_password.sass
# NAME Members_change_password

div.content! { 
  
  h3 "Change your password."

  form.change_password_form!(:action=>"/change-password/{{code}}/{{email}}/", :method=>"post") {
  
    fieldset {
      label 'Password'
      input.text( :id=>"password", :name=>"password", :type=>"password", :value=>'' )
    }
    
    fieldset {
      label { span 'Confirm Password'  }
      input.text( :id=>"confirm_password", :name=>"confirm_password", :type=>"password", :value=>'' )
    }
    
    div.buttons {
      button.create 'Get My Password', :onclick=>"document.getElementById('change_password_form!').submit(); return false;" 
    }
    
  } # form
  
  
} # === div.content!

partial('__nav_bar')

