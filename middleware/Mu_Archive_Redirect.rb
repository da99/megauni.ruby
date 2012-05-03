
require "./middleware/Find_The_Bunny"
class Mu_Archive_Redirect

  def initialize new_app
    @app = new_app
  end

  def call e
    dup._call e
  end

  def _call new_env

    @e = new_env
    path_info = new_env['PATH_INFO']
    bing_site = 'http://www.bing.com/'

    %w{ e qa news shop predictions random }.each { |suffix|
      if path_info[ %r!\A/uni/(da01tv)/#{suffix}/\Z! ]
        return redirect("/life/#{$1}/#{suffix}/")
      end
    }

    if path_info[ %r!/uni/?\Z! ]
      return redirect("/search/")
    end

    if path_info == '/timer/'
      return redirect( '/busy-noise/' )
    end

    if path_info['/myeggtimer%']
      return redirect( '/myeggtimer/' )
    end

    %w{ back.pain meno.osteo child.care }.each { |wrong|
      right = wrong.gsub('.', '-')
      if new_env['PATH_INFO'] =~ %r"/#{wrong}/clubs/#{wrong}/(.+)?"
        return redirect("/#{right}/#{$1}")
      end
    }

    %w{ back-pain meno-osteo child-care }.each { |right|
      wrong = right.sub '-', '_'
      if path_info =~ %r!#{wrong}!
        return redirect( path_info.gsub(wrong,right) )
      end
    }
    
    if path_info === '/' && new_env['HTTP_METHOD'] === 'POST'
      return redirect( new_env['HTTP_REFERER'] || '/my-egg-timer/' )
    end

    if path_info == '/member/' && %w{HEAD GET}.include?(new_env['HTTP_METHOD'])
      return redirect('/')
    end
    
    # =========== WRONG URLS ==============================
    if new_env['PATH_INFO'] == '/templates/'
      return redirect('/')
    end 
    
    # =========== BAD AGENTS ==============================
    if [
     %r!\A/MSOffice/cltreq.asp!,
     %r!\.(asp|php)\Z!,
     %r!\A/_vti_bin/owssvr.dll!,
     %r!\A/sitemap.xml.gz!,
     %r!awstats.pl\Z!,
     %r!\A/my-egg-timer/stylesheets/\Z!
    ].detect { |str| new_env['PATH_INFO'] =~ str }
      return redirect("http://www.bing.com/")
    end

    wrong_path = %w{
      /SWF/main.swf
      /(null)/
    }.detect { |str| new_env['PATH_INFO'] == str }
    if wrong_path
      return redirect("http://www.bing.com#{wrong_path}")
    end

    if new_env['PATH_INFO']['/+/']
      new_url = File.join( *(new_env['PATH_INFO'].split('+').reject { |piece| piece == '+'}) )
      return redirect(new_url)
    end

    
    ua = new_env['HTTP_USER_AGENT']
    if ua && [ 'libwww-perl', 'LinkWalker/', 'TwengaBot',  
    'panscient', 'aiHitBot' , "WebSurfer text" , "Yandex/", 'YandexBot', "Sosospider"].detect { |ua_s|  
      ua[ua_s]
    }
      return redirect("http://www.bing.com/")
    end

    if ua 
      
      if ua['Yahoo! Slurp/'] && path_info['/SlurpConfirm404']
        return redirect( bing_site )
      end
      
      if ua['Googlebot/']
        wrong_paths = %w{ vb forum forums old vbulletin }.map { |dir| "/#{dir}/" }
        if wrong_paths.include?(path_info)
          return redirect( bing_site )
        end
      end
      
    end # if ua


    # =====================================================
    
    if new_env['PATH_INFO'] === "/skins/jinx/css/main_show.css"
      return redirect("/stylesheets/en-us/Hellos_list.css")
    end

    if new_env['PATH_INFO'] === "/skins/jinx/css/news_show.css"
      return redirect("/stylesheets/en-us/Hellos_list.css")
    end

    if ['/salud/robots.txt'].include?(new_env['PATH_INFO'])
      return redirect("/robots.txt")
    end

    if (new_env['HTTP_HOST'] =~ /megahtml.com/ && new_env['PATH_INFO'] == '/')
      return redirect('/megahtml.html')
    end
    
    if (new_env['HTTP_HOST'] =~ /myeggtimer.com/ && new_env['PATH_INFO'] == '/')
      return redirect('/my-egg-timer/moving.html')
    end

    if (new_env['HTTP_HOST'] =~ /busynoise.com/ && new_env['PATH_INFO'] == '/') ||
       ['/egg', '/egg/'].include?(new_env['PATH_INFO'])
      return redirect('/busy-noise/moving.html')
    end

    if new_env['PATH_INFO'] =~ %r!\A/uni/(#{Find_The_Bunny::Old_Topics.join('|')})/\Z!
      return redirect("/#{$1}/")
    end

    
    if new_env['PATH_INFO'] === '/rss/'
      return redirect("/rss.xml")
    end
    
    @app.call(new_env)

  end

  private

  def redirect new_url
    response = Rack::Response.new
    response.redirect( new_url, 301 ) # permanent
    response.finish
  end


end # === class

__END__

