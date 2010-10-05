
require 'sinatra'

get '/' do
  %~
<html>
  <body>
    <p>Go to:</p>
    <a href="http://www.megauni.com/salud/">megauni.com/salud</a><body>
  </body>
</html>
  ~
end

get 'googlehostedservice.html' do
  'googled80ce82f00e7fc31'
end
