
class Messages
  
  include Base_Control

  def GET_by_id id  # SHOW
    mess_id = if id.to_s.size < 4
                "message-#{id}"
              else
                id
              end
    env['message_by_id'] = Message.by_id(mess_id) 
    render_html_template
  end

  def GET_by_label club, label # LIST
    env['message_label'] = label
    env['messages_by_label'] = Message.by_club_id_and_public_label("club-" + club, label)
    render_html_template
  end
  
  def GET_by_date club, year = 2006, month = 1 # LIST
    env['list.year'] = year
    env['list.month'] = month
    env['list.messages'] = Message.by_published_at(year, month)
    render_html_template
  end

  def POST # CREATE
    begin
      clean_room[:target_ids] ||= []
      clean_room[:lang]       = self.current_member.lang
      clean_room[:owner_id]   = "username-#{clean_room[:username]}"
      
      Message.create( current_member, clean_room )
      
      flash_msg.success = "Your message has been saved."
      redirect! '/' 
      
    rescue Member::Invalid
      flash_msg.errors= $!.doc.errors 
      redirect! "/lives/#{clean_room[:username]}/"
    end
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
      redirect! "/mess/#{id}/"
    rescue Message::Invalid
      flash_msg.errors = $!.doc.errors
      redirect! "/mess/#{id}/edit/"
    end
  end
  
  def GET_edit id # EDIT 
    mess_id = if id.to_s.size < 8
                "message-#{id}"
              else
                id
              end
    mess = env['results.message'] = Message.by_id(mess_id)
    require_log_in! 'ADMIN',  mess.data.username_id
    render_html_template
  end

  def DELETE id # DELETE
    success_msg { "Delete: #{doc.data.title}"  }
    redirect_success '/my-work/' 
    crud! 
  end

end # === class
