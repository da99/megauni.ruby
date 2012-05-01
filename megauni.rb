
require 'sinatra/base'

class The_App < Sinatra::Base
  set :sessions, false
  
  not_found {
    e = env['sinatra.error']
    
    archive = File.join("public/heroku-mongo/", request.path_info )
    archive_index = File.join(archive, "/index.html")
    
    txt = case e.code
    when 404, '404'
      file = [archive, archive_index].detect { |f| File.file? f }
      if file
        status 200
        File.read(file)
      end
    end
    
    if The_App.development?
      txt ||= archive
    end
    txt || pass
  }
  
end # === class The_App
