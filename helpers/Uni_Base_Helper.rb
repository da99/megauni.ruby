

module Sinatra
  module Uni_Base_Helper

    def lang
    'en-us'
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
