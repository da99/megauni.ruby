# middleware/Mu_Archive_Redirect.rb

describe :Control_Old_Apps_Read do


# 
#
# Note: when setting 'SERVER_NAME', the value 
# changes back to the default, 'example.org', 
# after a redirect. 
# 
# This means you won't be able to have multiple 
# redirects if settings a 'SERVER_NAME', because
# it would not reflect real-world conditions.
#
#

  it 'shows a moving message for www.myeggtimer.com' do
    domain = 'www.myeggtimer.com'
    get '/', {}, { 'HTTP_HOST'=> domain }
    follow_redirect!
    last_response.body.should.match /over to the new address/
  end 

  it 'redirect /timer/ to /busy-noise/' do
    get '/timer/'
    assert_redirect '/busy-noise/'
  end

  it 'redirect /myeggtimer%5C/ to /myeggtimer/' do
    get '/myeggtimer%5C/'
    assert_redirect "/myeggtimer/"
  end

  it 'should redirect www.busynoise.com/ to /busy-noise/moving.html' do
    domain = 'www.busynoise.com'
    get '/', {}, { 'HTTP_HOST' =>domain  }
    follow_redirect!
    assert_equal '/busy-noise/moving.html', last_request.fullpath
  end

  it 'should redirect www.busynoise.com/egg to /busy-noise/moving.html' do
    domain = 'www.busynoise.com'
    get '/egg', {}, { 'HTTP_HOST' =>domain  }
    follow_redirect!
    follow_redirect!
    assert_equal '/busy-noise/moving.html', last_request.fullpath
  end

  it 'shows a moving message for www.busynoise.com/egg/' do
    domain =  'www.busynoise.com/'
    get '/egg/', {}, { 'HTTP_HOST'=> domain }
    follow_redirect!
    last_response.body
    .should.match /This website has moved/
  end

  it 'shows a moving message for www.busynoise.com/egg' do 
    domain =  'www.busynoise.com'
    get '/egg', {}, { 'HTTP_HOST'=> domain }
    follow_redirect!
    follow_redirect!
    last_response.body
    .should.match /This website has moved/
  end

  it 'redirect /salud/robots.txt to /robots.txt' do
    get '/salud/robots.txt'
    follow_redirect!
    assert_equal '/robots.txt', last_request.fullpath
  end

  it 'redirect /skins/jinx/css/main_show.css to /stylesheets/en-us/Hellos_list.css' do
    get '/skins/jinx/css/main_show.css'
    follow_redirect!
    assert_equal "/stylesheets/en-us/Hellos_list.css", last_request.fullpath
  end

  it 'redirect /skins/jinx/css/news_show.css to /stylesheets/en-us/Hellos_list.css' do
    get '/skins/jinx/css/news_show.css'
    follow_redirect!
    assert_equal "/stylesheets/en-us/Hellos_list.css", last_request.fullpath
  end

  it 'redirect any 404 url ending in /+/ to ending /' do
    get '/missing/page/+/'
    assert_redirect "/missing/page/"
  end

  it 'redirect /templates/ to /' do
    get '/templates/'
    assert_redirect '/'
  end

end # === class Test_Control_Old_Apps_Read
