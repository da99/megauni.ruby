# MAB   ~/megauni/templates/en-us/html/Members_change_password.rb
# SASS  ~/megauni/templates/en-us/css/Members_change_password.sass
# NAME  Members_change_password

class Members_change_password < Base_View

  def title 
    'Change your password.'
  end

  def code
    app.the.code
  end

  def email
    app.the.email
  end
  
end # === Members_change_password 
