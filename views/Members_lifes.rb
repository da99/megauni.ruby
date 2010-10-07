# MAB   ~/megauni/templates/en-us/mab/Members_lifes.rb
# SASS  ~/megauni/templates/en-us/sass/Members_lifes.sass
# NAME  lifes
# CONTROL models/Member.rb
# MODEL   controls/Member.rb

class Members_lifes < Base_View

  def title 
    'Your Lifes'
  end

  def lifes
    # [{'username'=>'Not done', 'href'=>'/no-where'}]
    current_member.lifes.username_for
  end
  
  def session_form_username
    @app.clean_room[:add_username]
  end
  
end # === lifes 
