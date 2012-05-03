# controls/Clubs.rb

# Originally, the Hearts Club used to be it's own
# website at: SurferHearts.com
# This test makes sure it handles the old urls
# when SurferHearts.com redirects to the Hearts Club
# on MegaUni.com
describe :Control_Surfer_Hearts_Read do

  it 'renders page w/ assets: /heart_link/{id}/' do
    get '/heart_link/10/'
    should_render
  end

  it 'redirects /mess/{id}/ with ids under 200 to /heart_link/{id}/' do
    [1, 10, 143].each { |id|
      get "/mess/#{id}/"
      assert_redirect "/heart_link/#{id}/", 301
    }
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
  
  it 'renders page w/assets: /blog/' do
    get '/blog/'
    should_render
  end

  it 'redirects /uni/hearts/ to /blog/' do 
    get '/uni/hearts/'
    assert_redirect '/blog/'
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

  it 'redirects /uni/hearts/by_label/stuff_for_dudes/ => /heart_links/by_category/14/' do
    get '/uni/hearts/by_label/stuff_for_dudes/'
    assert_redirect '/heart_links/by_category/14/'
  end

  it 'responds with 404 for a heart link that does not exist.' do
    get "/heart_link/1000000/"
    last_response.status.should == 404
    # assert_match( /Document not found for Message id: .1000000./, err.message )
  end

  it 'redirects "/rss/" to "/rss.xml".' do
    get '/rss/'
    follow_redirect!
    assert_equal '/rss.xml', last_request.fullpath 
  end

  (14..22).to_a.each { |id|

    prefix = "/heart_links/by_category/#{id}"
    
    it "renders page w/assets: #{prefix}/" do
      get "#{prefix}/"
      should_render
    end
    
    it "redirects #{prefix}.html to .../#{id}/" do
      get "#{prefix}.html"
      assert_redirect "#{prefix}/", 301
    end
    
  }

end # === class Test_Control_Club_Hearts_Read
