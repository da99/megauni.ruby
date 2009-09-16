describe 'The Main App' do

  it "shows homepage: / " do
    get '/'
    last_response.should.be.ok
    last_response.body.should =~ /megauni/i
  end

  it "shows /busy-noise" do
    get '/busy-noise'
    follow_redirect!
    last_response.should.be.ok
  end

  it "shows /my-egg-timer" do
    get '/my-egg-timer'
    follow_redirect!
    last_response.should.be.ok
  end

  it "adds a slash to a file path" do
    get '/busy-noise'
    follow_redirect!
    last_request.path_info.should.be =~ /noise\/$/
    last_response.should.be.ok
  end

  it "does not add a slash to a missing file: cat.png" do
    get '/dir/cat.png'
    last_response.status.should.be == 404
  end

  it "shows: sitemap.xml as xml" do
    get '/sitemap.xml' 
    last_response.should.be.ok
    last_response.content_type.should.be == 'application/xml;charset=utf-8'
  end

  it "renders /help/" do
    get '/help/'
    last_response.should.be.ok
  end

end # === The Main App




