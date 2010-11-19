# MAB   ~/megauni/templates/en-us/html/Members_life.rb
# SASS  ~/megauni/templates/en-us/css/Members_life.sass
# NAME  Members_life

require 'views/__Base_View_Member_Life'

class Members_life < Base_View

  include Base_View_Member_Life

  def title 
    "The Universe of #{app.the.username}"
  end

  def stream
    @stream ||= begin
                  compile_messages app.the.life.find.messages.
                    privacy('public').
                    message_model(%w{fact question status buy comment}).
                    go!
                end
  end
  
end # === Members_life 
