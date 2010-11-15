# MAB   ~/megauni/templates/en-us/html/Members_lifes.rb
# SASS  ~/megauni/templates/en-us/css/Members_lifes.sass
# NAME  lifes
# CONTROL models/Member.rb
# MODEL   controls/Member.rb

class Members_lifes < Base_View

  def title 
    'Your Lifes'
  end

  def lifes
    # [{'username'=>'Not done', 'href'=>'/no-where'}]
    current_member.find.lifes.go!.map { |doc| 
      doc[:href] = "/life/#{doc['username']}/"
      doc
    }
  end
  
  def session_form_username
    @app.clean_room[:add_username]
  end
  
end # === lifes 
