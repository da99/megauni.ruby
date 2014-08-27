# controls/Hellos.rb


describe :Control_Hellos do

  it 'show homepage: /' do
    get '/'
    assert_equal 200, last_response.status
  end

  it 'respond to HEAD /' do
    head '/'
    assert_equal 200, last_response.status
  end

  it 'respond to HEAD /salud/' do
    head '/salud/'
    assert_equal 200, last_response.status
  end

  it "shows /busy-noise" do
    get '/busy-noise'
    follow_redirect!
    assert_equal 200, last_response.status
  end

  it "shows /my-egg-timer" do
    get '/my-egg-timer'
    follow_redirect!
    assert_equal 200, last_response.status
  end

  it "adds a slash to a path" do
    get '/busy-noise'
    last_response.headers['Location'].should.match /noise\/$/
  end

  it "adds a slash to path, not query string" do
    get '/shiina-ringo?album=1'
    should_redirect "/shiina-ringo/?album=1", 301
  end

  it "does not add a slash to a missing file: cat.png" do
    get '/dir/cat.png'
    assert_equal 404, last_response.status
  end

  it "renders /sitemap.xml as xml" do
    get '/sitemap.xml' 
    assert_equal 200, last_response.status
    assert_equal 'application/xml;charset=utf-8', last_response.content_type
  end

  it "renders /help/" do
    get '/help/'
    should_render
  end

  it 'render /rss.xml as xml' do
    get '/rss.xml'
    assert_equal 200, last_response.status
    assert_equal 'application/xml;charset=utf-8', last_response.content_type
  end

  it "redirects /rss/ to /rss.xml" do
    get '/rss/'
    assert_redirect "/rss.xml"
  end
  
end # === class Test_Control_Hellos
