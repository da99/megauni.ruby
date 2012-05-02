# controls/Clubs.rb

describe :Control_Clubs_Read do

  it "does not render /uni/" do
    get '/uni/'
    assert_equal false, last_response.ok?
  end

  it 'renders /salud/' do
    get "/salud/"
    assert_equal 200, last_response.status
  end

  %w{ meno-osteo back-pain }.each { |name|
    it "renders /#{name}/" do
      get "/#{name}/"
      assert_equal 200, last_response.status
    end
  }

  %w{ back-pain meno-osteo }.each { |right|
    wrong = right.sub('-', '_')

    it "redirects /#{wrong}/ to /#{right}/" do
      get "/#{wrong}/"
      follow_redirect!
      assert_equal "/#{right}/", last_request.path_info
      assert_equal 200, last_response.status
    end
  }

  it 'not show follow club link to strangers.' do
    get "/arthritis/"
    assert_equal nil, last_response.body["follow"]
    assert_equal 200, last_response.status
  end

  # ================ Club Search ===========================

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

  %w{ 
    arthritis back-pain cancer child-care computer dementia
    depression flu hair health heart hiv housing
    meno-osteo preggers 
  }.each { |name|
    it "redirects /uni/#{name}/ to /#{name}/" do
      get "/uni/#{name}/"
      assert_redirect "/#{name}/", PERM
    end

    it "renders /#{name}/" do
      get "/#{name}/"
      last_response.status.should == 200
    end
  }

end # === class Test_Control_Clubs_Read


