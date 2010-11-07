# MAB   ~/megauni/templates/en-us/html/Members_life.rb
# MAB   ~/megauni/templates/en-us/html/Members_life_e.rb
# MAB   ~/megauni/templates/en-us/html/Members_life_qa.rb
# MAB   ~/megauni/templates/en-us/html/Members_life_status.rb
# 
# SASS  ~/megauni/templates/en-us/css/Members_life.sass
# SASS  ~/megauni/templates/en-us/css/Members_life_e.sass
# SASS  ~/megauni/templates/en-us/css/Members_life_qa.sass
# SASS  ~/megauni/templates/en-us/css/Members_life_status.sass
# 
# CONTROL ~/megauni/controls/Members.rb
#
# NAME  Member_Life


module Base_View_Member_Life

  def life_club_href
    "/life/#{username}/"
  end

  def username
    app.the.username
  end
  
  def owner
    app.the.owner
  end

  def owner?
    current_member == owner
  end

  def owner_username_id
    @cache_username_id ||= app.the.owner.lifes._id_for(username)
  end

  def username_id
    owner_username_id
  end

  def compiled_owner_messages model
    cache_name = "@cache_mess_#{model}".to_sym
    instance_variable_get(cache_name) || 
      instance_variable_set(cache_name, compile_messages(
        Message.public(:owner_id=>owner_username_id, :message_model=>model)
      ))
  end

end # === Base_View_Club
