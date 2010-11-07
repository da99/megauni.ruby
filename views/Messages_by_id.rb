# MAB   ~/megauni/templates/en-us/html/Messages_by_id.rb
# SASS  ~/megauni/templates/en-us/css/Messages_by_id.sass
# NAME  Messages_by_id
# MODEL models/Message

class Messages_by_id < Base_View

  delegate_date_to :message, %w{ published_at }
  delegate_to 'message.data', :owner_id, :answer, :_id, :message_model, :title
  delegate_to :message, %w{ 
    href 
    href_notify 
    href_repost 
    href_edit 
    href_log 
    href_parent
    href_section
    href_club
    message_model_in_english 
    message_section 
    clubs
  }
  
  def show_moving_message?
    from_surfer_hearts?(message.data.as_hash)
  end

  def page_title 
    message.data.title || 
      (message.data.as_hash.has_key?('old_id') && message.data._id.to_s.sub('message-', 'Message ID: ')) ||
        ( "Message ID: #{message.data._id}" )
  end

  def notify_me?
    !notifys.empty?
  end

  def reposts
    @cache_message_reposts ||= message.reposts(current_member)
  end

  def editor_id
    @cache_editor_id ||= current_member_username_ids.detect { |id| id == owner_id }
  end

  def message
    app.the.message
  end
  
  def owner?
    current_member_username_ids.include?(owner_id)
  end

  def suggestions_or_answers
    is_question? ? 
      "Answers and Suggestions:" :
      "Suggestions:" 
  end

  def is_question?
    message.data.message_model == 'question'
  end

  def message_title
    message.data.title || '~ ~ ~ ~'
  end


  def data
    @cache_message_data ||= begin
                                v= message.data.as_hash
                                v[:compiled_body] = from_surfer_hearts?(v) ? v['body'] : auto_link(v['body'])
                                v
                              end
  end

  def updator?
    message.updator?(current_member)
  end

  def updated?
    !!message.data.updated_at
  end
  
  def has_parent?
    message.data.parent_message_id
  end
  
  def club
    clubs.first
  end

  def club_title
    club.data.title
  end

  %w{ questions critiques suggests }.each { |mod|
    eval %~
      def #{mod}
        @cache_messages_#{mod} ||= compile_messages(message.#{mod}, message.data.as_hash)
      end
    ~
  }
  
  def notifys
    @cache_message_notifys ||= message.notifys(current_member)
  end

  def notify_menu
    @cache_notify_menu ||= message.notifys( current_member ).menu
  end
  
  def repost_menu
    @cache_repost_menu ||= message.reposts( current_member ) .menu
  end

end # === Messages_by_id 
