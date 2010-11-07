# MAB   ~/megauni/templates/en-us/html/Members_account.rb
# SASS  ~/megauni/templates/en-us/css/Members_account.sass
# NAME  Members_account

class Members_account < Base_View

  def title 
    "Your Account on #{site_name}"
  end

  def messages
    @cache_messages_my ||= compile_messages(current_member.messages_from_my_clubs)
  end

end # === Members_account 
