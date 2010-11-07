# MAB   ~/megauni/templates/en-us/html/Clubs_read_qa.rb
# SASS  ~/megauni/templates/en-us/css/Clubs_read_qa.sass
# NAME  Clubs_read_qa

require 'views/extensions/Base_Club'

class Clubs_read_qa < Base_View
 
  include Views::Base_Club

  def title 
    return "Q & A: #{club_title}" if not club.is_a?(Life)
    "Q & A with #{club_filename}"
  end

  def questions
    compile_and_cache('messages.questions', app.the.questions )
  end
  
end # === Clubs_read_qa 
