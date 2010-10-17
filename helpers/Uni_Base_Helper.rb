require 'models/Dyno_Cache'

module Sinatra
  module Uni_Base_Helper

    def the_message
      the.id = clean[:id]
      the.message = Message.find._id(the.id).go_first!
    end

    def the_club
      the.filename = clean_params[:filename]
      the.club = Club.find.filename(filename).go_first!
    end

    def the_club_with messages
      the_club
      the.send("#{messages}=",  the.club.find.messsages.send(messages).go! )
    end

    def the_life
      the.username = clean_params[:filename]
      the.life = Life.find.username(filename).go_first!
    end
    
    def the_life_with messages
      the_life
      the.send("#{messages}=", the.life.find.messsages.send(messages).go! )
    end

    def current_path path = nil
      puts "Not done: current_path"
    end

    def base_path path
      puts "Not done: base_path"
    end

    def redirect! raw_url
      url = expand_url( raw_url )
      raise "not implemented"
    end

    def redirect_back_or raw_url
      url = expand_url( raw_url )
      raise "Not implemented."
    end
    
    def expand_url txt
      raise "not done"
      # add slash at end
      # if url starts with "../"
    end

    def lang
    'en-us'
    end

    def the
      @the_cache ||= Dyno_Cache.new
    end

    def stardardize_year yr
      year = yr.to_i
      year += 2000 if year < 100
      year
    end

    def stardardize_month mt
      month = mt.to_i
      month = 1 if month < 1
      month
    end
    
    def stardardize_date_range yr, mt = 0
      year  = stardardize_year( yr )
      month = stardardize_month( mt )
      case month
      when 1
        prev_month = Time.utc(year - 1, 12)
        next_month = Time.utc(year + 1, 2)
      when 12
        prev_month = Time.utc(year, 11)
        next_month = Time.utc(year, 1)
      else
        prev_month = Time.utc(year, month-1)
        next_month = Time.utc(year, month+1)    
      end
      [ year, month, prev_month, next_month]
    end

    def cache_for min 
      header :cache_control, "public, max-age=#{min * 60}"
    end

    def control name = :get_control_value
      case name
      when :get_control_value
        @control
      else
        @control = name
      end
    end

    def action name = :get_control_value
      case name
      when :get_control_value
        raise "Action name not set." if !!@action
        @action
      else
        @action = name
      end
    end

    # ------------------------------------------------------------------------------------
    private # ----------------------------------------------------------------------------
    # ------------------------------------------------------------------------------------

    def success_msg *args
      return @success_msg if args.empty?
      @success_msg = args.first
    end

  end # === module Uni_Base_Helper
  
  helpers Uni_Base_Helper
end # === Sinatra

__END__

  
  # def redirect_back! *args
  #   args[0] = env['HTTP_REFERER'] || args[0]
  #   redirect! *args
  # end

  # def redirect! *args
  #   render_text_plain ''
  #   
  #   # If HTTP Code not specified, use 303.
  #   # This forces redirect as a GET.
  #   if not args.last.is_a?(Integer)
  #     args << 303 
  #   end
  #   
  #   response.redirect( *args )
  #   raise Uni_App::Redirect
  # end

  # def not_found! body
  #   error! body, 404
  # end

  # # Halt processing and return the error status provided.
  # def error!(body, code = 500)
  #   response.status = code
  #   response.body   = body unless body.nil?
  #   raise Uni_App.const_get("HTTP_#{code}")
  # end
