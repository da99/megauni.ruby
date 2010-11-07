# MAB   ~/megauni/templates/en-us/html/Members_follows.rb
# SASS  ~/megauni/templates/en-us/css/Members_follows.sass
# NAME  follows
# CONTROL models/Member.rb
# MODEL   controls/Member.rb

class Members_follows < Base_View

  def title 
    'My Follows'
  end
  
  def stream
    [] #compile_messages(app.current_member.stream(current_member_username))
  end
  
  def usernames
    []
  end

  def clubs_not_owned?
    []
  end

end # === follows 
