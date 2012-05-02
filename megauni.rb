
require 'sinatra/base'

class The_App < Sinatra::Base
  Perma = 301
  Missing = 404
  set :sessions, false

  get "/today/" do
    redirect to("/"), Perma
  end

  %w{ sitemap rss }.each { |name|
    get "/#{name}.xml" do
      headers 'Content-Type' => 'application/xml;charset=utf-8'
      Mu_Archive_Read "/#{name}.xml"
    end
  }

  post "/search/" do 
    name = params['name'] || params['keyword']
    retro = "/#{name}/"
    redirect(to("/#{name}/"), Perma) if Mu_Archive(retro)
    
    case name
    when %r!menop..se!, %r!ost[eo]+p[oris]+!
      redirect to("/meno-osteo/"), Perma
    else
      Mu_Archive_Read "/search/index.html", :name=>name
    end
  end # === post search

  post "/club-search/" do
    redirect to("/search/"), Perma
  end

end # === class The_App
