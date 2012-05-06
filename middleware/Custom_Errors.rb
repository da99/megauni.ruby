

class Custom_Errors

  def initialize the_app
    @app = the_app
  end

  def call e
    orig = @app.call e
    
    case orig.first
    when 100..399
      orig
    else
      keys = %w{ 
        rack.request.query_hash 	
        rack.request.query_string 	
        rack.url_scheme 	
        HTTP_ACCEPT 	
        HTTP_ACCEPT_LANGUAGE 	
        HTTP_HOST 	
        HTTP_USER_AGENT 	
        PATH_INFO 	
        QUERY_STRING 	
        REMOTE_ADDR 	
        REQUEST_METHOD 	
        REQUEST_PATH 	
        REQUEST_URI 	
        SCRIPT_NAME 	
        SERVER_NAME 	
        SERVER_PROTOCOL 	
      }
      
      Dex.insert e['sinatra.error'], Hash[ keys.zip e.values_at(*keys) ]
      r = Rack::Response.new
      r.status= orig.first
      r.body = [ File.read("public/#{orig.first}.html") ]
      r.finish
    end
    
  end # === def call e
  
end # === class Custom_Errors
