# MAB   ~/megauni/templates/en-us/html/Messages_edit.rb
# SASS  ~/megauni/templates/en-us/css/Messages_edit.sass
# NAME  Messages_edit

class Messages_edit < Base_View

  def title 
    'Edit: ' + (mess.data.title || mess.data._id.to_s)
  end
  
  def mess_href
    @cache_mess_href ||= mess.href
  end

  def mess_data
    @cache_mess_data ||= begin
                             hash = mess.data.as_hash
                             hash['title'] ||= nil
                             hash
                           end
  end

  def mess
    app.the.message
  end

  def mess_id
    mess.data._id
  end

  def editor_id
    current_member.lifes._ids.first
  end
  
end # === Messages_edit 
