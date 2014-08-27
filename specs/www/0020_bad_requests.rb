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
    it "redirects /#{dir}/ to #{BING_URL} if Googlebot" do
      header 'USER_AGENT', 'SOMETHING Googlebot/5.1'
      get "/#{dir}/"
      redirects_to BING_URL
    end
  }

  it_redirects 301, "/manager/status/", 'http://www.honoringhomer.net/'

  it "redirects 'head /manager/status/' to http://www.honoringhomer.net/" do
    head "/manager/status/"
    redirects_to 301, "http://www.honoringhomer.net/"
  end

  it_redirects PERM, "/admin/spaw/spacer.gif", BING_URL

end # === class Test_Control_Bad_Requests
