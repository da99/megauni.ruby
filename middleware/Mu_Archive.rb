require 'mustache'

def Mu_Archive path_info
  p = path_info
  
  if p == '/help/'
    return Mu_Archive.join("/uni/megauni/index.html")
  end

  archive       = Mu_Archive.join path_info
  archive_index = Mu_Archive.join path_info, "/index.html"

  [archive, archive_index].detect { |f| File.file? f }
end # === def Mu_Archive

def Mu_Archive_Read path_info, vals = Hash[]
  content = File.read( Mu_Archive path_info )
  Mustache.raise_on_context_miss = true
  Mustache.render( content, vals )
end

class Mu_Archive

  Perma = 301
  Dir   = "public/heroku-mongo"

  def self.join *args
    File.join( Dir, *args )
  end

  def initialize new_app
    @app = new_app
  end

  def call new_env

    path_info = new_env['PATH_INFO']
    orig = @app.call(new_env)
    
    return orig unless orig.first.to_s == "404"
    
    f = Mu_Archive(path_info)
    return orig unless f
    
    r = Rack::Response.new
    r.body= [ File.read(f) ]
    r.finish

    # r = Rack::Response.new
    # r.body= [ File.read(f) ]
    # r.finish
  end

end # === class

__END__

