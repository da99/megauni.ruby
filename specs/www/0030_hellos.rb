# controls/Hellos.rb


describe '/' do

  it 'show homepage: /' do
    get '/'
    http_code.should == 200
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

  it "redirects w/ 302 /help to /" do
    get '/help'
    redirects_to 302, '/'
  end

end # === class Test_Control_Hellos
