# controls/Clubs.rb

describe "Old Pages:" do

  it "renders /salud" do
    get "/salud"
    last_response.status.should == 200
    html.should.match /Jabon/
  end

  %w{
      meno-osteo back-pain  uni/mike-in-tokyo-rogers uni/liberty 
      arthritis back-pain cancer child-care computer dementia
      depression flu hair health heart hiv housing
      meno-osteo preggers 
  }.uniq.each { |name|
    it_redirects PERM, "/uni/#{name}/",   "/#{name}"
    it_redirects PERM, "/clubs/#{name}/", "/#{name}"

    it "renders /#{name}" do
      get "/#{name}"
      last_response.status.should == 200
    end
  }

  %w{ back-pain meno-osteo }.each { |right|
    wrong = right.sub('-', '_')

    it "redirects /#{wrong} to /#{right}" do
      get "/#{wrong}"
      follow_redirect!
      last_request.path_info.should == "/#{right}"
      last_response.status.should == 200
    end
  }

  it 'redirect /child_care/clubs/child_care/ to /child-care' do
    get '/child_care/clubs/child_care'
    follow_redirect!
    assert_equal '/child-care', last_request.fullpath
  end

  it 'redirect /back_pain/clubs/back_pain/ to /clubs/back_pain/' do
    get '/back_pain/clubs/back_pain/'
    follow_redirect!
    assert_equal '/back-pain/', last_request.fullpath
  end

  # ================ Club Search ===========================

  it "redirects /uni/ to /search/" do
    get '/uni/'
    assert_redirect "/search/"
  end

  it "redenrs GET /search/" do
    get "/search/"
    last_response.should.be.ok
  end

  it "redirects /club-search/ to /search/ (both using POST)" do
    post "/club-search/", :keyword=>"factor"
    assert_redirect "/search/", 301
  end

  it 'shows full list of clubs for /search/{filename}/' do
    keyword = 'factor' + rand(1000).to_s
    post "/search/", :keyword=>keyword
    r = last_response
    r.status.should == 200
    r.body.should.match %r!arthritis!i
  end

  it 'redirect to club profile page if only one club found' do
    post "/search/", :keyword=>"meno-osteo"
    assert_redirect "/meno-osteo/", PERM
  end

end # === class Test_Control_Clubs_Read


