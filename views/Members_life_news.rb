# MAB   ~/megauni/templates/en-us/html/Members_life_news.rb
# SASS  ~/megauni/templates/en-us/css/Members_life_news.sass
# NAME  Members_life_news

class Members_life_news < Base_View

  include Base_View_Member_Life

  def title 
    "#{username}'s News & Status"
  end
  
end # === Members_life_news 
