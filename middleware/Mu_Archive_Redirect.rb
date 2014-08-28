
class Mu_Archive_Redirect

  BAD_AGENT_FK     = %r! f.cking !i
  BAD_AGENTS       = %w{ fucking ZmEu }.map(&:downcase)
  BING_URL         = 'http://www.mises.org/'
  TIMER_REGEX      = %r!/timer/?\Z!i
  MYEGGTIMER_REGEX = /\/myeggtimer.\/?/i
  Old_Topics = %w{
    arthritis
    back-pain
    cancer
    child-care
    computer
    dementia
    depression
    economy
    flu
    hair
    health
    heart
    hiv
    housing
    music
    meno-osteo
    news
    preggers
    sports
  }

  def initialize new_app
    @app = new_app
  end

  def call e

    o = @app.call(e)
    return o unless o.first == 404

    path_info = e['PATH_INFO']
    user_agent = e['HTTP_USER_AGENT'] || ""

    BAD_AGENTS.each { |a|
      if user_agent.downcase[a]
        return redirect(BING_URL)
      end
    }

    return redirect( '/busy-noise' ) if path_info[TIMER_REGEX]
    return redirect( '/myeggtimer' ) if path_info[MYEGGTIMER_REGEX]
    return redirect("http://www.honoringhomer.net/") if path_info == '/manager/status'
    return redirect("/blog", 302) if '/heart_links/by_category/new' == path_info
    return redirect(BING_URL) if "/admin/spaw/spacer.gif" == path_info

    %w{ back.pain meno.osteo child.care }.each { |wrong|
      right = wrong.gsub('.', '-')
      if path_info =~ %r"/#{wrong}/clubs/#{wrong}/(.+)?"
        return redirect("/#{right}/#{$1}")
      end
    }

    %w{ back-pain meno-osteo child-care }.each { |right|
      wrong = right.sub '-', '_'
      if path_info =~ %r!#{wrong}!
        return redirect( path_info.gsub(wrong,right) )
      end
    }

    if path_info === '/' && e['HTTP_METHOD'] === 'POST'
      return redirect( e['HTTP_REFERER'] || '/my-egg-timer/' )
    end

    if path_info == '/member/' && %w{HEAD GET}.include?(e['HTTP_METHOD'])
      return redirect('/')
    end

    # =========== WRONG URLS ==============================
    if path_info == '/templates/'
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
    ].detect { |str| path_info =~ str }
      return redirect(BING_URL)
    end

    wrong_path = %w{
      /SWF/main.swf
      /(null)/
    }.detect { |str| path_info == str }
    if wrong_path
      return redirect("http://www.bing.com#{wrong_path}")
    end

    if path_info['/+/']
      new_url = File.join( *(path_info.split('+').reject { |piece| piece == '+'}) )
      return redirect(new_url)
    end


    ua = e['HTTP_USER_AGENT']
    if ua && [ 'libwww-perl', 'LinkWalker/', 'TwengaBot',
    'panscient', 'aiHitBot' , "WebSurfer text" , "Yandex/", 'YandexBot', "Sosospider"].detect { |ua_s|
      ua[ua_s]
    }
      return redirect(BING_URL)
    end

    if ua

      if ua['Yahoo! Slurp/'] && path_info['/SlurpConfirm404']
        return redirect( BING_URL )
      end

      if ua['Googlebot/']
        wrong_paths = %w{ vb forum forums old vbulletin }.map { |dir| "/#{dir}/" }
        if wrong_paths.include?(path_info)
          return redirect( BING_URL )
        end
      end

    end # if ua


    # =====================================================

    if path_info === "/skins/jinx/css/main_show.css"
      return redirect("/stylesheets/en-us/Hellos_list.css")
    end

    if path_info === "/skins/jinx/css/news_show.css"
      return redirect("/stylesheets/en-us/Hellos_list.css")
    end


    if (e['HTTP_HOST'] =~ /megahtml.com/ && path_info == '/')
      return redirect('/megahtml.html')
    end

    if (e['HTTP_HOST'] =~ /myeggtimer.com/ && path_info == '/')
      return redirect('/my-egg-timer/moving.html')
    end

    if (e['HTTP_HOST'] =~ /busynoise.com/ && path_info == '/') ||
       ['/egg', '/egg/'].include?(path_info)
      return redirect('/busy-noise/moving.html')
    end

    if path_info =~ %r!\A/(uni|clubs)/([a-z0-9\-\.\_]+)/?\Z!i
      return redirect("/#{$2}")
    end

    return redirect("/robots.txt") if path_info['robots.txt']
    return redirect("/rss.xml") if path_info === '/rss/'
    return redirect("/heart_link/57") if path_info['surfboard-usb']

    o
  end

  private

  def redirect new_url, stat = 301
    response = Rack::Response.new
    response.redirect( new_url, stat ) # permanent
    response.finish
  end


end # === class

__END__

