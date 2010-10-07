
class Messages
  
  include Base_Control

  private
  def id_to_mess raw_id
    id = raw_id.to_s.strip
    env['message_by_id'] = if id.size < 6
                             Message.by_old_id(id)
                           else
                             Message.by_id(id)
                           end
  end

  public
  def GET_by_id raw_id  # SHOW
    id_to_mess(raw_id)
    render_html_template
  end

  def GET_doc_log raw_id
    id_to_mess(raw_id)
    render_html_template
  end

  def GET_by_label club_filename, raw_label # LIST
    club = Club.by_filename(club_filename.to_s.strip)
    label = raw_label.to_s.strip
    env['message_label'] = label
    env['messages_by_label'] = Message.by_club_id_and_public_label(club.data._id, label)
    render_html_template
  end
  
  def GET_by_date club, year = 2006, month = 1 # LIST
    env['list.year'] = year
    env['list.month'] = month
    env['list.messages'] = Message.by_published_at(year, month)
    render_html_template
  end

  def POST_create # CREATE
    return_page = [clean_room[:return_url]].compact.detect { |path| 
      path[%r!\A[a-zA-Z0-9/\.\-\_]+\Z!] 
    }
    default_return_page = '/lifes/'
    begin
      if clean_room[:club_filename]
        club = Club.by_filename_or_member_username(clean_room[:club_filename])
        return_page ||= club.href
        clean_room[:target_ids] = [club.data._id]
      else
        clean_room[:target_ids] = clean_room[:target_ids].to_s.split(',').map(&:to_s)
      end
      clean_room[:lang]       = self.current_member.lang
      

      clean_room[:owner_id]   = current_member.lifes._id_for(clean_room[:username])
      
      Message.create( current_member, clean_room )
      
      flash_msg.success = "Your message has been saved."
      redirect_back!( return_page || default_return_page )
      
    rescue Member::Invalid
      flash_msg.errors= $!.doc.errors 
      redirect_back!( return_page || default_return_page )
    end
  end

  def POST_notify mess_id
    render_text_plain clean_room.inspect
  end

  def POST_repost
    render_text_plain clean_room.inspect
  end

  # def PUT id # UPDATE
  #   success_msg(lambda { |doc| "Update: #{doc.data.title}" })
  #   params = clean_room.clone
  #   params[:tags] = begin
  #                     new_tags = []
  #                     new_tags += clean_room[:new_tags].to_s.split("\n") 
  #                     new_tags += clean_room[:tags]
  #                     new_tags.uniq
  #                   end
  #   handle_rest :params=>params
  # end

  def PUT_by_id id
    require_log_in!
    mess_id = if id.to_s.size < 8
                "message-#{id}"
              else
                id
              end
    begin
      mess = Message.update( mess_id, current_member, clean_room )
      flash_msg.success = "Message saved."
      redirect_back! "/mess/#{id}/"
    rescue Message::Invalid
      flash_msg.errors = $!.doc.errors
      redirect_back! "/mess/#{id}/edit/"
    end
  end
  
  def GET_edit id # EDIT 
    mess_id = if id.to_s.size < 8
                "message-#{id}"
              else
                id
              end
    mess = env['results.message'] = Message.by_id(mess_id)
    require_log_in! 'ADMIN',  mess.data.owner_id
    render_html_template
  end

  def DELETE id # DELETE
    success_msg { "Delete: #{doc.data.title}"  }
    redirect_success '/my-work/' 
    crud! 
  end

end # === class
