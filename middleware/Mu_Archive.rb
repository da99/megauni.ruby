
class Mu_Archive

  def initialize new_app
    @app = new_app
  end

  def call new_env

    path_info = new_env['PATH_INFO']
    orig = @app.call(new_env)
    
    return(orig) unless orig.first.to_s == "404"
    
    f = file(path_info)
    return(orig) unless f
    
    request = Rack::Request.new(new_env)
    response = Rack::Response.new
    response.body= [ File.read(f) ]
      
    response.finish
  end

  def file path_info
    archive = File.join("public/heroku-mongo/", path_info )
    archive_index = File.join(archive, "/index.html")
    
    [archive, archive_index].detect { |f| File.file? f }
  end

end # === class

__END__

