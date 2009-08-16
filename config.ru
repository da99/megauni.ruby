my_app_root = File.expand_path( File.dirname(__FILE__) )

require( my_app_root + '/miniuni.rb' )
    
run Sinatra::Application

