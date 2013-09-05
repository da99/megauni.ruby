my_app_root = File.expand_path( File.dirname(__FILE__) )

begin
  require( my_app_root + '/miniuni.rb' )
rescue
  require 'sinatra'
  before {
    halt( %~
      <html>
        <head><title>Mega Fail</title></head>
        <body>
          <h1>Super Duper Mega Fail</h1>
          <h2>Check it.</h2>
        </body>
      </html>
    ~ )
  }
end
run Sinatra::Application

