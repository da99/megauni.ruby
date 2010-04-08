require 'views/Club_Control_Base_View'

class Clubs
  
  include Base_Control

  def GET_list
    env['results.clubs'] = Club.all
    render_html_template
  end

  def GET_create
    require_log_in!
    render_html_template
  end

  def GET_follow_by_id filename
    club = Club.by_filename(filename)
    begin
      club.create_follower(current_member)
    rescue Couch_Plastic::Invalid
      flash_msg.errors = $!.doc.errors
    end
    redirect! club.href
  end

  def GET_by_id filename
    env['results.club'] = club = Club.by_filename(filename)
    env['results.messages_latest'] = Message.latest_by_club_id(club.data._id)
    case filename
    when 'hearts'
      render_html_template "Clubs_#{filename}"
    else
      render_html_template
    end
  end
  
  def GET_by_old_id id
    env['results.club'] = id
    return render_html_template("Topic_#{id}")
    # template = begin
    #   File.read("templates/#{lang}/mustache/Topic_#{id}.html")
    # rescue Errno::ENOENT => e
    #   require "middleware/Mab_In_Disguise"
    #   Mab_In_Disguise.compile "templates/#{lang}/mab/Topic_#{id}.rb"
    # end

    # mustache_class = Class.new(Base_View) do
    #   def title
    #   end
    # end
    # mustache_class.raise_on_context_miss = true
    # mustache_class.new(self).render(template)
  end

  def POST
    require_log_in!
    begin
      club = Club.create( current_member, clean_room )
      flash_msg.success = "Club has been created: #{club.data.title}"
      redirect! club.href
    rescue Club::Invalid
      flash_msg.errors = $!.doc.errors
      redirect! "/today/"
    end
  end

  def PUT_by_id filename
    require_log_in! 
    club_id = Club.by_filename(filename).data._id
    begin
      club = Club.update(club_id, current_member, clean_room)
      flash_msg.success = "Club has been updated."
      redirect! club.href
    rescue Club::Invalid
      flash_msg.errors = $!.doc.errors
      redirect! File.join(club.href, 'edit/')
    end
  end

  def GET_edit club_filename
    club = save_club_to_env(club_filename)
    require_log_in! :ADMIN, club.data.username_id
    render_html_template
  end

  private # ======================================

  def save_club_to_env id
    club_filename       = "#{id.sub('club-', '')}"
    env['the.app.club'] = Club.by_filename club_filename
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
