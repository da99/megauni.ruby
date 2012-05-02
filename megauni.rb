
require 'sinatra/base'
require './middleware/Heroku_Mongo_Archive'

class The_App < Sinatra::Base
  set :sessions, false
  
end # === class The_App
