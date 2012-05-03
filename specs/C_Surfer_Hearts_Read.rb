# controls/Clubs.rb

# Originally, the Hearts Club used to be it's own
# website at: SurferHearts.com
# This test makes sure it handles the old urls
# when SurferHearts.com redirects to the Hearts Club
# on MegaUni.com
describe :Control_Surfer_Hearts_Read do

  it 'renders /uni/hearts/ w/ assets' do
    get '/uni/hearts/'
    should_render
  end

  it 'redirects /hearts/ to /club/hearts/' do
    get "/hearts/"
    follow_redirect!
    assert_equal( "/uni/hearts/", last_request.fullpath)
  end
  
  it 'redirects /hearts/m/ to /uni/hearts/' do 
    get '/hearts/m/'
    follow_redirect! # to /hearts/
    follow_redirect! # finally, to our destination.
    assert_equal '/uni/hearts/', last_request.fullpath 
  end

  it 'redirects /blog/ to /uni/hearts/' do 
    get '/blog/'
    follow_redirect!
    assert_equal '/uni/hearts/', last_request.fullpath
    assert_equal 200, last_response.status
  end

  it 'redirects /about/ to /help/' do
    get '/about/'
    follow_redirect!
    assert_equal '/help/', last_request.fullpath
  end

  it 'redirects blog archives (e.g. "/blog/2007/8/" ) to news archives. ' do
    get '/blog/2007/8/'
    follow_redirect!
    assert_equal '/uni/hearts/by_date/2007/8/', last_request.fullpath
  end

  it 'redirects archives by_category to messages archives by_label. ' +
     '(E.g.: /heart_links/by_category/16/)' do
      get '/heart_links/by_category/167/'
      follow_redirect!
      assert_equal '/uni/hearts/by_label/stuff_for_dudes/', last_request.fullpath 
  end

  it 'redirects a "/heart_link/10/" to "/mess/10/".' do
    get "/heart_link/10/"
    follow_redirect!
    assert_equal "/mess/10/", last_request.fullpath 
  end

  it 'responds with 404 for a heart link that does not exist.' do
    get "/heart_link/1000000/"
    follow_redirect!
    last_response.status.should == 404
    # assert_match( /Document not found for Message id: .1000000./, err.message )
  end

  it 'redirects "/rss/" to "/rss.xml".' do
    get '/rss/'
    follow_redirect!
    assert_equal '/rss.xml', last_request.fullpath 
  end


end # === class Test_Control_Club_Hearts_Read
