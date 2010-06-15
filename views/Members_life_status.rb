# MAB   ~/megauni/templates/en-us/mab/Members_life_status.rb
# SASS  ~/megauni/templates/en-us/sass/Members_life_status.sass
# NAME  Members_life_status

require 'views/__Base_View_Member_Life'

class Members_life_status < Base_View

  include Base_View_Member_Life

	def title 
    "What are you doing, #{username}?"
  end

	def statuses
		[]
	end
  
end # === Members_life_status 