class Slashify_Path_Ending
  
  def initialize new_app
    @app = new_app
  end
  
  def call new_env

    ext = File.extname(new_env['PATH_INFO'])
    add_slash = (['HEAD', 'GET'].include?(new_env['REQUEST_METHOD']) && 
       new_env['PATH_INFO'][-1,1] != '/' && 
       ext === '')
    return(@app.call( new_env )) unless add_slash

    req  = Rack::Request.new(new_env)
    response = Rack::Response.new
    
    qs = req.query_string.strip.empty? ? nil : req.query_string
    new = [ req.path_info + '/', qs ].compact.join('?')
    
    response.redirect( new, 301 ) # permanent
    response.finish
    
  end
  
end # === Allow_Only_Roman_Uri
