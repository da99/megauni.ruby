
# class String
  # alias_method :each, :each_line
# end

class Surfer_Hearts_Archive

  Perma = 301
  Dir   = "public/surferhearts.com"

  def self.join *args
    File.join( Dir, *args )
  end

  def self.path? path, r
    path[ %r!\A#{r}\Z! ]
  end

  def initialize new_app
    @app = new_app
  end

  def join *args
    self.class.join( *args )
  end

  def path? *args
    self.class.path?( *args )
  end

  def render f
    resp = Rack::Response.new
    resp.body = [ File.read(f) ]
    resp.finish
  end

  def call e
    dup._call e
  end

  def _call new_env

    e = new_env
    path_info = new_env['PATH_INFO']
    
    if path?( path_info, "/uni/hearts/?" )
      r = render( join("index.html") )
      return r
    end

    if path?( path_info, "/heart.link/(\d+)/?" )
      resp = Rack::Response.new
      resp.redirect "/mess/#{$1}/", Perma
      return resp.finish
    end

    if path?( path_info, "/mess/(\d{1,3})/?" )
      file = join("heart_link/#{$1}/index.html")
      return render( file) if File.file?(file)
    end

    @app.call(new_env)
  end

end # === class

__END__

