# controls/Bad_Requests.rb


describe :Control_Bad_Requests do

  it 'redirect any favicon.ico requests to /favicon.ico' do
    get "/my-egg-timer/favicon.ico"
    follow_redirect!
    "/favicon.ico".should == last_request.fullpath
  end
  
  it 'redirect /SWF/main.swf to http://www.bing.com/SWF/main.swf' do
    get "/SWF/main.swf"
    follow_redirect!
    "http://www.bing.com/SWF/main.swf".should == last_response.headers['Location']
  end

  it 'redirect /(null)/ to http://www.bing.com/(null)/' do
    get "/(null)/"
    follow_redirect!
    "http://www.bing.com/(null)/".should == last_response.headers['Location']
  end

  %w{ vb forum forums old vbulletin}.each { |dir|
    it "redirects /#{dir}/ to http://www.bing.com/ if Googlebot" do
      get "/#{dir}/", {}, 'HTTP_USER_AGENT' => 'SOMETHING Googlebot/5.1'
      assert_redirect "http://www.bing.com/"
    end
  }

  it_redirects 301, "/manager/status/", 'http://www.honoringhomer.net/'

end # === class Test_Control_Bad_Requests
