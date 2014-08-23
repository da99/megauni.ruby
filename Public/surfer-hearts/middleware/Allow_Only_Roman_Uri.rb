class Allow_Only_Roman_Uri
  
  def initialize new_app
    @app = new_app
  end
  
  def call new_env
    invalid = new_env['REQUEST_URI'][/[^a-zA-Z0-9\_\-\/\.]+/] 
    valid_static = new_env['REQUEST_URI'].split('?')
    if invalid && !valid_static
      content = "<h1>Not Found</h1>"
      res = Rack::Response.new
      res.status = 404
      res.body   = content
      res.finish
    else
      @app.call new_env
    end
  end
  
end # === Allow_Only_Roman_Uri
