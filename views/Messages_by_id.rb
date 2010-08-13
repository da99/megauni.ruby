# MAB   ~/megauni/templates/en-us/mab/Messages_by_id.rb
# SASS  ~/megauni/templates/en-us/sass/Messages_by_id.sass
# NAME  Messages_by_id
# MODEL ~/megauni/models/Message.rb

class Messages_by_id < Base_View

  delegate_date_to :message, %w{ published_at }
  delegate_to 'message.data', :owner_id, :answer, :_id, :message_model
  delegate_to :message, %w{ 
    href 
    href_notify 
    href_repost 
    href_edit 
    href_log 
    href_parent
    message_model_in_english 
    message_section 
    clubs
  }
  
  def show_moving_message?
    from_surfer_hearts?(message.data.as_hash)
  end

  def title 
    message.data.title || 
      (message.data.as_hash.has_key?('old_id') && message.data._id.to_s.sub('message-', 'Message ID: ')) ||
        ( "Message ID: #{message.data._id}" )
  end

  def notify_me?
    !notifys.empty?
  end

  def reposts
    cache['message_reposts'] ||= message.reposts(current_member)
  end

  def editor_id
    @cache['editor_id'] ||= current_member_username_ids.detect { |id| id == owner_id }
  end

  def message
    @app.env['message_by_id']
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

  def message_section_href
    suffix = case message_section
      when Message::SECTIONS::E
        'e'
      when Message::SECTIONS::QA
        'qa'
      else
        message_section.to_s.downcase.split.join('_')
      end
    File.join(club_href, suffix + '/')
  end

  def data
    cache[:message_data] ||= begin
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

  def club_href
    club.href
  end

  %w{ questions critiques suggests }.each { |mod|
    eval %~
      def #{mod}
        cache['messages.#{mod}'] ||= compile_messages(message.#{mod}, message.data.as_hash)
      end
    ~
  }

  def notify_menu
    cache[:notify_menu] ||= current_member.notifys_menu( message )
  end
  
  def notifys
    cache['message_notifys'] ||= message.notifys(current_member)
  end

end # === Messages_by_id 
