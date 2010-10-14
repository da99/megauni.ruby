require 'helpers/Pony'

class Members
  include Base_Control
    
  # ============= Member Actions ==========================          

  def GET_create_account 
    render_html_template
  end

  def GET_create_life
    require_log_in!
    render_html_template
  end
            
  def POST_create
    log_out! 

    begin
      clean_room[:add_life] ||= 'friend'
      m = Member.create( current_member, clean_room )
      self.current_member = m
      flash_msg.success = "Your account has been created."
      redirect! '/lifes/' 
      
    rescue Member::Invalid

      flash_msg.errors= $!.doc.errors 
      session[ :form_username  ] = clean_room[:username] 
               
      redirect! '/create-account/' 
    end
      
  end # == post :create


  # =========================== MEMBER ONLY ==========================================

  def GET_today
    require_log_in!
    render_html_template
  end
  
  def GET_follows
    require_log_in!
    render_html_template
  end
  
  def GET_notifys
    require_log_in!
    render_html_template
  end

  def GET_lifes
    require_log_in!
    render_html_template
  end

  %w{e qa news shop predictions random }.each { |path|
    eval(%~
          def GET_life_#{path} un
            redirect!("/uni/\#{un}/#{path}/", 301)
          end
         ~)
  }

  def GET_life_status un
    redirect!(request.path_info.sub('status/', 'news/').sub('life', 'clubs'), 301)
  end

  def POST_reset_password
    env['results.email'] = clean_room['email']
    
    begin
      mem       = Member.by_email( clean_room['email'] )
      code      = mem.reset_password
      env['results.reset'] = true
      reset_url = File.join(Uni_App::SITE_URL, "change-password", code, CGI.escape(mem.data.email), '/')
      Pony.mail(
        :to    =>clean_room['email'], 
        :from  =>Uni_App::SITE_HELP_EMAIL, 
        :subject=>"#{Uni_App::SITE_DOMAIN}: Lost Password",
        :body  =>"To change your old password, go to:\n#{reset_url}"
        # :via      => :smtp,
        # :via_options => { 
        #   :authentication => Uni_App::SMTP_AUTHENTICATION,
        #   :address   => Uni_App::SMTP_ADDRESS,
        #   :user_name => Uni_App::SMTP_USER_NAME,
        #   :password  => Uni_App::SMTP_PASSWORD,
        #   :domain    => Uni_App::SMTP_DOMAIN
        # }
      )
    rescue Member::Not_Found
    end
      
    render_html_template
  end

  def GET_change_password code, email
    env['results.member'] = Member.by_email(CGI.unescape(email))
    env['results.code']   = code
    env['results.email']  = email
    render_html_template
  end

  def POST_change_password code, email
    mem = Member.by_email(CGI.unescape(email))
    begin
      mem.change_password_through_reset(
        :code=>code, 
        :password=>clean_room[:password], 
        :confirm_password=>clean_room[:confirm_password]
      )
      flash_msg.success = "Your password has been updated."
      redirect! '/log-in/'
    rescue Member::Invalid
      flash_msg.errors = $!.doc.errors
      redirect! "/change-password/#{code}/#{email}/"
    end
  end
        
  def PUT_update
    begin
      m = Member.update( current_member.data._id, current_member, clean_room )
      flash_msg.success = "Data has been updated and saved."
      if clean_room['add_username']
        redirect! "/life/#{m.clean_data.add_username}/"
      else
        redirect! '/lifes/'
      end
    rescue Member::Invalid
      flash_msg.errors= $!.doc.errors 
      session[:add_username] = clean_room['add_username']
      redirect_back! "/lifes/"
    end
  end # === put :update

  def DELETE_delete_account_forever_and_ever
    Member.delete( current_member.data._id, current_member )
    log_out!
    flash_msg.success = "Your account has been deleted forever."
    redirect! '/'
  end

end # === Member_Control

