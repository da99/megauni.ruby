# MAB   ~/megauni/templates/en-us/html/Members_life_shop.rb
# SASS  ~/megauni/templates/en-us/css/Members_life_shop.sass
# NAME  Members_life_shop

class Members_life_shop < Base_View

  include Base_View_Member_Life

  def title 
    "#{username}'s Shop"
  end

  def buys
    compiled_owner_messages 'shop'
  end
  
end # === Members_life_shop 
