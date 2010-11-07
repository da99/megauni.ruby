# MAB   ~/megauni/templates/en-us/html/Members_life_qa.rb
# SASS  ~/megauni/templates/en-us/css/Members_life_qa.sass
# NAME  Members_life_qa

class Members_life_qa < Base_View

  include Base_View_Member_Life

  def title 
    "Q&A for #{username}"
  end

  def questions
    compiled_owner_messages 'question'
  end
  
end # === Members_life_qa 
