# controls/Clubs.rb
require 'tests/__rack_helper__'

# Originally, the Hearts Club used to be it's own
# website at: SurferHearts.com
# This test makes sure it handles the old urls
# when SurferHearts.com redirects to the Hearts Club
# on MegaUni.com
class Test_Control_Surfer_Hearts_Read < Test::Unit::TestCase

  must 'render /uni/hearts/' do
    get '/uni/hearts/'
    assert_equal 200, last_response.status
  end

  must 'redirects /hearts/ to /club/hearts/' do
    get "/hearts/"
    follow_redirect!
    assert_equal( "/uni/hearts/", last_request.fullpath)
  end
  
  must 'redirects /hearts/m/ to /uni/hearts/' do 
    get '/hearts/m/'
    follow_redirect! # to /hearts/
    follow_redirect! # finally, to our destination.
    assert_equal '/uni/hearts/', last_request.fullpath 
  end

  must 'redirects /blog/ to /uni/hearts/' do 
    get '/blog/'
    follow_redirect!
    assert_equal '/uni/hearts/', last_request.fullpath
    assert_equal 200, last_response.status
  end

  must 'redirects /about/ to /help/' do
    get '/about/'
    follow_redirect!
    assert_equal '/help/', last_request.fullpath
  end

  must 'redirects blog archives (e.g. "/blog/2007/8/" ) to news archives. ' do
    get '/blog/2007/8/'
    follow_redirect!
    assert_equal '/uni/hearts/by_date/2007/8/', last_request.fullpath
  end

  must 'redirects archives by_category to messages archives by_label. ' +
     '(E.g.: /heart_links/by_category/16/)' do
      get '/heart_links/by_category/167/'
      follow_redirect!
      assert_equal '/uni/hearts/by_label/stuff_for_dudes/', last_request.fullpath 
  end

  must 'redirects a "/heart_link/10/" to "/mess/10/".' do
    news_id = Message.by_published_at(:limit=>1).first['_id'].to_s.sub('message-', '')
    get "/heart_link/#{news_id}/"
    follow_redirect!
    assert_equal "/mess/#{news_id}/", last_request.fullpath 
  end

  must 'responds with 404 for a heart link that does not exist.' do
    err= begin
      get "/heart_link/1000000/"
      follow_redirect!
    rescue Mongo_Dsl::Not_Found => e
      e
    end
    assert_match( /Document not found for Message id: .1000000./, err.message )
  end

  must 'redirects "/rss/" to "/rss.xml".' do
    get '/rss/'
    follow_redirect!
    assert_equal '/rss.xml', last_request.fullpath 
  end


end # === class Test_Control_Club_Hearts_Read
