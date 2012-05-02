
require 'sinatra/base'

class The_App < Sinatra::Base
  Perma = 301
  Missing = 404
  set :sessions, false
  
  post "/search/" do 
    name = params['name'] || params['keyword']
    retro = "/#{name}/"
    redirect(to("/#{name}/"), Perma) if Mu_Archive(retro)
    Mu_Archive_Read "/search/index.html", :name=>name
  end # === post search

end # === class The_App
