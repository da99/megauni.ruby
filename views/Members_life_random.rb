# MAB   ~/megauni/templates/en-us/html/Members_life_random.rb
# SASS  ~/megauni/templates/en-us/css/Members_life_random.sass
# NAME  Members_life_random

class Members_life_random < Base_View

  include Base_View_Member_Life

  def title 
    "The Random Thoughts of #{username}"
  end
  
end # === Members_life_random 
