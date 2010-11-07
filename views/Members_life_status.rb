# MAB   ~/megauni/templates/en-us/html/Members_life_status.rb
# SASS  ~/megauni/templates/en-us/css/Members_life_status.sass
# NAME  Members_life_status

class Members_life_status < Base_View

  include Base_View_Member_Life

  def title 
    "What are you doing, #{username}?"
  end

  def statuses
    compiled_owner_messages 'status' 
  end
  
end # === Members_life_status 
