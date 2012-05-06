

class Custom_Errors

  def initialize the_app
    @app = the_app
  end

  def call e
    orig = @app.call e
    
    case orig.first
    when 403, 404, 500
      r = Rack::Response.new
      r.status= orig.first
      r.body = [ File.read("public/#{orig.first}.html") ]
      r.finish
    else
      orig
    end
    
  end # === def call e
  
end # === class Custom_Errors
