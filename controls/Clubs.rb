require 'views/Club_Control_Base_View'

class Clubs
  
  include Base_Control
  
  SECTIONS = %w{ e qa news fights shop random thanks predictions magazine}
  
  top_slash # =====================================================
  
  get '/club-create' do
    require_log_in!
    render_html_template
  end

  get '/club_search' do
    env['club_filename'] = filename
    begin
      club = Club.by_filename(filename)
      redirect!("/uni/#{club.data.filename}/")
    rescue Club::Not_Found
    end
    render_html_template
  end

  post '/club_search/:filename' do
    filename = clean_room['keyword'].to_s
    begin
      club = Club.by_filename_or_member_username(filename)
      redirect!("/uni/#{club.data.filename}/")
    rescue Club::Not_Found
      cgi_filename = CGI.escape(filename)
      redirect!("/club-search/#{cgi_filename}/")
    end
  end

  path '/uni' # =====================================================
  
  get '/' do
    env['results.clubs'] = Club.all
    render_html_template
  end

  post '/create' do
    require_log_in!
    begin
      club = Club.create( current_member, clean_room )
      flash_msg.success = "Club has been created: #{club.data.title}"
      redirect! club.href
    rescue Club::Invalid
      flash_msg.errors = $!.doc.errors
      redirect_back! "/lifes/"
    end
  end

  post '/follow' do
    username_id = current_member.lifes._id_for(clean_room['username'])
    club        = Club.by_filename(clean_room['filename'])
    begin
      club.create_follower(current_member, username_id)
    rescue Couch_Plastic::Invalid
      flash_msg.errors = $!.doc.errors
    end
    redirect! club.href
  end
  
  get '/:old_topic' do # by_old_id id
    env['results.club'] = id
    render_html_template("Topic_#{id}")
  end

  path '/:filename' # =====================================================

  get '/' do # by_filename filename
    env['results.club'] = club = Club.by_filename_or_member_username(filename)
    env['results.messages_latest'] = Message.latest_by_club_id(club.data._id)
    case filename
    when 'hearts'
      render_html_template "Clubs_#{filename}"
    else
      render_html_template
    end
  end
  
  put '/' do # update filename
    require_log_in! 
    club_id = Club.by_filename(filename).data._id
    begin
      club = Club.update(club_id, current_member, clean_room)
      flash_msg.success = "Club has been updated."
      redirect! club.href
    rescue Club::Invalid
      flash_msg.errors = $!.doc.errors
      redirect! club.href_edit
    end
  end

  get '/edit' do # club_filename
    club_filename = clean_room[:filename]
    club = save_club_to_env(club_filename)
    require_log_in! :ADMIN, club.data.owner_id
    render_html_template
  end

  get '/follow' do
    filename = clean_room[:filename]
    clean_room['username'] = current_member.lifes.usernames.first
    clean_room['filename'] = filename
    POST_follow()
  end
  
  get '/news' do
    filename = clean_params[:filename]
    env['results.club'] = club = Club.by_filename_or_member_username(filename)
    env['results.news'] = Message.latest_by_club_id(club.data._id, :message_model=>'news')
    render_html_template
  end

  get '/magazine' do
    filename = clean_params[:filename]
    env['results.club'] = club = Club.by_filename_or_member_username(filename)
    env['results.magazine'] = Message.latest_by_club_id(club.data._id, :message_model=>'mag_story')
    render_html_template
  end

  get '/fights' do
    filename = clean_params[:filename]
    env['results.club'] = club = Club.by_filename_or_member_username(filename)
    env['results.passions'] = Message.latest_by_club_id(club.data._id, :message_model=>{ :$in=> %w{fight complaint debate} })
    render_html_template
  end

  get '/qa' do
    filename = clean_params[:filename]
    env['results.club'] = club = Club.by_filename_or_member_username(filename)
    env['results.questions'] = Message.latest_by_club_id(club.data._id, :message_model=>'question')
    render_html_template
  end

  get '/e' do
    filename = clean_params[:filename]
    env['results.club'] = club = Club.by_filename_or_member_username(filename)
    env['results.facts'] = Message.latest_by_club_id(club.data._id, :message_model=>{:$in=>['e_chapter', 'e_quote']})
    render_html_template
  end

  get '/shop' do
    filename = clean_params[:filename]
    env['results.club'] = club = Club.by_filename_or_member_username(filename)
    env['results.buys'] = Message.latest_by_club_id(club.data._id, :message_model=>'buy')
    render_html_template
  end

  get '/predictions' do
    filename = clean_params[:filename]
    env['results.club'] = club = Club.by_filename_or_member_username(filename)
    env['results.predictions'] = Message.latest_by_club_id(club.data._id, :message_model=>'prediction')
    render_html_template
  end

  get '/random' do
    filename = clean_params[:filename]
    env['results.club'] = club = Club.by_filename_or_member_username(filename)
    env['results.randoms'] = Message.latest_by_club_id(club.data._id, :message_model=>'random')
    render_html_template
  end

  get '/thanks' do
    filename = clean_params[:filename]
    env['results.club'] = club = Club.by_filename_or_member_username(filename)
    env['results.thanks'] = Message.latest_by_club_id(club.data._id, :message_model=>'thank')
    render_html_template
  end
  
  private # ======================================

  def save_club_to_env id
    club_filename       = "#{id.sub('club-', '')}"
    env['the.app.club'] = Club.by_filename club_filename
    env['results.club'] = Club.by_filename club_filename
  end

  # =========================================================
  #               READ-related actions
  # =========================================================

  def GET_by_date  raw_year, raw_month
    year  = raw_year.to_i
    month = raw_month.to_i
    year += 2000 if year < 100
    month = 1 if month < 1
    case month
      when 1
        @prev_month = Time.utc(year - 1, 12)
        @next_month = Time.utc(year + 1, 2)
      when 12
        @prev_month = Time.utc(year, 11)
        @next_month = Time.utc(year, 1)
      else
        @prev_month = Time.utc(year, month-1)
        @next_month = Time.utc(year, month+1)    
    end
    @date = Time.utc(year, month)
    @news = News.by_published_at(:descending=>true, :startkey=>@next_month, :endkey=>@prev_month)
    render_html_template
  end # ===
  
end # === Club_Control



__END__

  
  def GET_as_life username
    env['club']            = Club.by_filename_or_member_username(username)
    env['messages_latest'] = Message.latest_by_club_id(env['club'].data._id)
    render_html_template
  end
