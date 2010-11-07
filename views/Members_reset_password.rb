# MAB   ~/megauni/templates/en-us/html/Members_reset_password.rb
# SASS  ~/megauni/templates/en-us/css/Members_reset_password.sass
# CONTROL ~/megauni/controls/Members.rb
# NAME  Members_reset_password

class Members_reset_password < Base_View

  def title 
    "Your password has been reset."
  end

  def email
    app.the.email
  end

  def reset?
    !!app.the.reset
  end
  
end # === Members_reset_password 
