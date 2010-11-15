$KCODE = 'utf8'

begin

  require 'megauni'
  
  my_app_root     = File.expand_path( File.dirname(__FILE__) )
  down_time_file  = File.join( my_app_root, '/helpers/sinatra/maintain')
  issue_client    = File.join( my_app_root, '/helpers/app/issue_client') 
  
  
  # === Protective
  use Rack::ContentLength
  use Allow_Only_Roman_Uri
  use Squeeze_Uri_Dots
  use Slashify_Path_Ending
  use Redirect_Mobile
  use Old_App_Redirect

  
  if Uni_App.development?
    use Rack::CommonLogger
    use Rack::ShowExceptions
    require 'middleware/Render_Css' 
    use Render_Css
  end

  # === Content Generators
  use Always_Find_Favicon
  use Serve_Public_Folder, ['/busy-noise/', '/my-egg-timer/', '/styles/', '/skins/']
  
  # === Helpers
  use Rack::MethodOverride
  use Rack::Session::Mongo, {:server=>File.join(MONGODB_CONN_STRING, DB_SESSION_TABLE) , :expire_after => (60*60*24*14) }
  use Strip_If_Head_Request
  
  # === Low-level Helpers 
  # === (specifically designed to run before Uni_App).
  
  # unless Uni_App.development?
  #   use Email_Exception
  #   # use Catch_Bad_Bunny
  #   # use Find_The_Bunny
  # end
  
  use Flash_Msg

  # Finally, start the app.
  run Uni_App

  
rescue Object => e
  
  if ['test', 'development'].include?(ENV['RACK_ENV'])
    raise e
  else
    begin
      require 'cgi'
      load File.expand_path('~/.megauni_conf')
      Pony.mail(
        :to=>'diego@miniuni.com', 
        :from=>'help@megauni.com',
        :subject => CGI.escapeHTML(e.class.to_s),
        :body    => CGI.escapeHTML(e.message.to_s),
        :via      => :smtp,
        :via_options => { 
          :address   => 'smtp.webfaction.com',
          :user_name => Uni_App::SMTP_USER_NAME,
          :password => Uni_App::SMTP_PASSWORD
        }
      )
    rescue Object => x
    end
  end
  
  the_app = lambda { |env|
    
    content = if env['REQUEST_METHOD'] === 'HEAD'
                ''
              elsif env["HTTP_X_REQUESTED_WITH"] === "XMLHttpRequest"
                %~<div class="error">Server Error. Try again later.</div>~
              else
                %~
                  <html>
                    <body>
                      <h1>Server Error.</h1>
                      <p>Try again later.</p>
                    </body>
                  </html>
                ~
              end
    
    [500, {'Content-Type' => 'text/html', 'Content-Length'=>content.size.to_s}, content]
    
  }
  
  run the_app
#   
end # === begin




