# middleware/Mu_Archive_Redirect.rb
require 'tests/__rack_helper__'

class Test_Control_Bad_Agents < Test::Unit::TestCase

  BING_URL = 'http://www.bing.com/'
  
  must 'redirect any path ending with .php to http://www.bing.com/' do
    get '/get_orders_list.php'
    assert_equal BING_URL, last_response.headers['Location']
  end
  
  must 'redirect any deep path (/.+/.+/index.php) to http://www.bing.com/' do
    get '/Site_old/administrator/index.php'
    assert_equal BING_URL, last_response.headers['Location']
  end

  must 'redirect any path ending with .asp to http://www.bing.com/' do
    get '/downloads/search.asp'
    assert_equal BING_URL, last_response.headers['Location']
  end

  must 'redirect any user agent containing "panscient" to http://www.bing.com' do
    get '/', {}, 'HTTP_USER_AGENT' => 'panscient.com'
    assert_equal BING_URL, last_response.headers['Location']
  end

  must( 'redirect any user agent containing "Yahoo! Slurp/" and ' +
       'looking for path start with /SlurpConfirm404' ) do
    get( 
      '/SlurpConfirm404/drodgers.htm', 
      {}, 
      'HTTP_USER_AGENT' => 'Mozilla/5.0 (compatible; Yahoo! Slurp/3.0; http://help.yahoo.com/help/us/ysearch/slurp)'
    )
    assert_equal BING_URL, last_response.headers['Location']
  end

  must 'redirect to http://www.bing.com/ if user agent is TwengaBot-Discover and page is missing' do
    ua = 'TwengaBot-Discover (http://www.twenga.fr/bot-discover.html)'
    get('/some/missin/page/', {}, 'HTTP_USER_AGENT' => ua)
    assert_equal BING_URL, last_response.headers['Location']
  end

  must 'redirect to http://www.bing.com/ if Sosospider and file is CSS' do
    ua = "Sosospider+(+http://help.soso.com/webspider.htm)"
    get("/stylesheets/en-us/hellos_list.css", {}, 'HTTP_USER_AGENT' => ua)
    assert_redirect BING_URL
  end

end # === class Test_Control_Old_Apps_Read
