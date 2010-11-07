# MAB   ~/megauni/templates/en-us/html/Members_life_e.rb
# SASS  ~/megauni/templates/en-us/css/Members_life_e.sass
# NAME  Members_life_e

class Members_life_e < Base_View

  include Base_View_Member_Life

  def title 
    "The Encyclopedia of #{username}"
  end

  def facts
    compiled_owner_messages 'fact'
  end
  
end # === Members_life_e 
