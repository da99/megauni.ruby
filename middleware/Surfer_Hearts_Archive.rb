
# class String
  # alias_method :each, :each_line
# end

class Surfer_Hearts_Archive

  Tags = { 
    14 => 'stuff_for_dudes', 
    15 => 'stuff_for_dudettes', 
    16 => 'stuff_for_pets', 
    17 => 'stuff_for_mommies_and_dads', 
    18 => 'edible_delicious', 
    19 => 'books_articles', 
    20 => 'techie_wonders', 
    21 => 'miscellaneous', 
    22 => 'art_design'
  }

  Unknown_Tags = {
    167 => 'stuff_for_dudes', 
    168 => 'stuff_for_dudettes', 
    169 => 'stuff_for_pets', 
    170 => 'stuff_for_mommies_and_dads', 
    171 => 'edible_delicious', 
    172 => 'books_articles', 
    173 => 'techie_wonders', 
    174 => 'miscellaneous', 
    175 => 'art_design', 
    176 => 'surfer_hearts',
  }



  Perma = 301
  Dir   = "public/surferhearts.com"

  def self.join *args
    File.join( Dir, *args )
  end

  def self.r r
    %r!\A#{r}\Z!
  end

  def r r
    self.class.r r
  end

  def self.path? path, r
    path =~ self.r(r)
    $~ 
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
    resp.body = [ File.read(join f) ]
    resp.finish
  end

  def redirect path
    respond { |r|
      r.redirect path, Perma
    }
  end

  def call e
    dup._call e
  end

  def respond
    r = Rack::Response.new
    yield r
    r.finish
  end

  def _call new_env

    e = new_env
    path_info = e['PATH_INFO']
    p = e['PATH_INFO']
    
    # heart_link categorys
    # 
    if m = path?(p, %r!/(heart|new|heart_link|new)s?/by_tag/(\d+)(/|\.html)?!) ||
       m = path?(p, %r!/heart.links?/by_category/(\d+)(.html)?!)
      return redirect("/heart_links/by_category/#{m.captures[0]}/")
    end
      
    if m = path?(p, %r!/heart_links/by_category/(\d+)/! )
      t = Tags[Integer(m.captures.first)]
      if t
        return render("/heart_links/by_category/#{m.captures.first}.html")
      end
    end
    
    # /uni/hearts/by_label/{tag}/ =>  /heart_links/by_category/{id}/
    if m = path?(p, %r!/uni/hearts/by_label/([^/]+)/! )
      
      t = Tags.key(m.captures.first)
      if t
        return redirect("/heart_links/by_category/#{t}/") 
      end
      
    end

    # /mess/13/ ==> /heart_link/13/
    if m = path?( path_info, %r"/mess/(\d{1,3})/?" )
      return redirect("/heart_link/#{m.captures.first}/") 
    end
    
    # /heart_link/20.html ==> /heart_link/20/
    if p =~ %r!\A/hearts?.links?/(\d+)\.html?\Z!  
      return redirect("/heart_link/#{1}/")
    end

    # /news/\d{1,3}/ => /heart_link/n/
    if p =~ r( %r!/(heart_links|news?)/(\d{1,3})/! )
      return redirect("/heart_link/#{$2}/")
    end

    # /uni/hearts/
    if p =~ %r"/uni/hearts/?" 
      return redirect( "/blog/" )
    end

    if p == '/blog/'
      return render( "index.html" )
    end

    # /heart_link/{id}/
    if m = path?( path_info, %r"/heart_link/(\d{1,3})/" )
      f = "heart_link/#{m.captures.first}.html"
      return render( f ) if File.file?(join f)
    end

    @app.call(new_env)
  end

end # === class

__END__
