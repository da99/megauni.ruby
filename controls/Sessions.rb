class Sessions
  include Base_Control

  def GET_log_in 
    render_html_template
  end

  def GET_log_out 
    log_out!
    flash_msg.success =  "You have been logged out." 
    redirect! '/'
  end

  def POST_log_in 

    log_out!
    
    begin 
      self.current_member = Member.authenticate(
        :username   => clean_room['username'], 
        :password   => clean_room['password'], 
        :ip_address => request.env['REMOTE_ADDR'],
        :user_agent => request.env['HTTP_USER_AGENT']
      )
      redirect!( session.delete(:return_page) || '/lifes/' )
      
    rescue Mongo_Dsl::Not_Found, Member::Wrong_Password
      flash_msg.errors = "Incorrect info. Try again."
      
    rescue Password_Reset::In_Reset
      flash_msg.errors = "Your password has been reset. Check your email for instructions." 
      
    end

    redirect! '/log-in/'
       
  end # === post_it_for

end # === Session_Control


