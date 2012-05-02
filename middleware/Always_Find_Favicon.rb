class Always_Find_Favicon
  
  def initialize new_app
    @app = new_app
  end
  
  def call new_env
    
    status, headers, body = @app.call( new_env )
    
    if status === 404 && 
       !(new_env['PATH_INFO'][%r!\A/favicon\.ico!]) &&
       new_env['PATH_INFO']['favicon.ico']
      
      request  = Rack::Request.new(new_env)
      response = Rack::Response.new
      full_uri = request.url.split('/')[0,3]

      # Redirec to http[s]://domain.com/favicon.ico
      response.redirect '/favicon.ico', 301 # Permanent
      response.finish
    else
      [status, headers, body]
    end
    
  end
  
end # === Allow_Only_Roman_Uri
