# controls/Hellos.rb


describe '/' do

  it 'show homepage: /' do
    get '/'
    assert_equal 200, last_response.status
  end

  it 'respond to HEAD /salud' do
    head '/salud'
    http_code.should == 200
  end

  it "shows /busy-noise" do
    get '/busy-noise'
    http_code.should == 200
  end

  it "shows /my-egg-timer" do
    get '/my-egg-timer'
    http_code.should == 200
  end

  it "renders /sitemap.xml as xml" do
    get '/sitemap.xml' 
    http_code.should == 200
    content_type.should == 'application/xml;charset=utf-8'
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
