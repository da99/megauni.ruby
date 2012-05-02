require 'mustache'

def Mu_Archive path_info
  archive = File.join("public/heroku-mongo/", path_info )
  archive_index = File.join(archive, "/index.html")

  [archive, archive_index].detect { |f| File.file? f }
end # === def Mu_Archive

def Mu_Archive_Read path_info, vals = Hash[]
  content = File.read(Mu_Archive(path_info))
  Mustache.raise_on_context_miss = true
  Mustache.render( content, vals )
end

class Mu_Archive

  def initialize new_app
    @app = new_app
  end

  def call new_env

    path_info = new_env['PATH_INFO']
    orig = @app.call(new_env)
    
    return(orig) unless orig.first.to_s == "404"
    
    f = Mu_Archive(path_info)
    return(orig) unless f
    
    request = Rack::Request.new(new_env)
    response = Rack::Response.new
    response.body= [ File.read(f) ]
      
    response.finish
  end

end # === class

__END__

