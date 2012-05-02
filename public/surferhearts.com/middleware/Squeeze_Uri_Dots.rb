class Squeeze_Uri_Dots
  
  def initialize new_app
    @app = new_app
  end
  
  def call new_env
    if new_env['REQUEST_URI']['..'] || new_env['REQUEST_URI']['./'] || new_env['REQUEST_URI']['/.'] # Using :REQUEST_URI includes query string
      squeezed = new_env['REQUEST_URI'].gsub(/\.+/, '.').gsub('./', '/').gsub('/.','/')
      res      = Rack::Response.new
      res.redirect squeezed, 301
      res.finish
    else
      @app.call new_env
    end
  end
  
end # === Squeeze_Uri_Dots
