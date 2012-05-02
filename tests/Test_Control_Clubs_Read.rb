  # must 'allow members to follow someone else\'s club' do
  #   club = create_club(regular_member(2))

  #   log_in_regular_member(1)
  #   get File.join('/', club.href, 'follow/')
  #   club = Club.find._id(club.data._id).go_first!
  #   follows = club.find.followers.go_first! Club.find.followers(
  #     :club_id=>, 
  #     :follower_id=>regular_member(1).lifes._ids.first
  #   ).to_a

  #   assert_equal 1, follows.size
  # end
# controls/Clubs.rb
require 'tests/__rack_helper__'

class Test_Control_Clubs_Read < Test::Unit::TestCase

  def mem
    @mem ||= regular_member(1)
  end

  must "not render /uni/" do
    get '/uni/'
    assert_equal false, last_response.ok?
  end

  must 'not render /uni/ for members' do
    log_in_regular_member(1)
    get '/uni/'
    assert_equal false, last_response.ok?
  end

  must 'be viewable by non-members' do
    club = create_club
    get "/uni/#{club.data.filename}/"
    assert_equal club.data.title, last_response.body[club.data.title]
  end
                                          
     

  must 'render /sports/' do
    get "/sports/"
    follow_redirect!
    assert_equal 200, last_response.status
  end

  must 'render /music/' do
    get "/music/"
    follow_redirect!
    assert_equal 200, last_response.status
  end


  must 'not show follow club link to strangers.' do
    club = create_club
    get club.href
    
    assert_equal nil, last_response.body[club.href_follow]
  end

  must 'not show follow club link to club creator' do
    club = create_club(regular_member(1))

    log_in_regular_member(1)
    get club.href
    assert_equal nil, last_response.body[club.href_follow]
  end

  must "not show \"You are following\" message to club creator" do
    club = create_club(regular_member(1))

    log_in_regular_member(1)
    get club.href
    assert_equal nil, last_response.body['following']
  end

  # ================ Club Search ===========================

  must 'redirect to /search/{filename}/ if more no club found' do
    keyword = 'factor' + rand(1000).to_s
    post "/search/", :keyword=>keyword
    follow_redirect!
    assert_equal "/search/#{keyword}/", last_request.path_info
  end

  must 'CGI.escape the filename in /search/{filename}/' do
    keyword = 'factor@factor' + rand(10000).to_s
    post "/search/", :keyword=>keyword
    follow_redirect!
    escaped = CGI.escape(keyword)
    assert_equal "/search/#{escaped}/", last_request.path_info
  end

  must 'redirect to club profile page if only one club found' do
    club = create_club(regular_member(1), :filename=>"sf_#{rand(10000)}")
    post "/search/", :keyword=>club.data.filename
    assert_redirect "/uni/#{club.data.filename}/", 302
  end

  must 'redirect to life if keyword is a member username' do
    un = regular_member(1).lifes.usernames.first
    post "/search/", :keyword=>un
    assert_redirect "/life/#{un}/", 302 # Temporary redirect.
  end

  # ================= Club Parts ===========================

  %w{ e  qa news magazine fights shop predictions random thanks }.each { |suffix|
    club = nil
    
    must "render /uni/..filename../#{suffix}/" do
      club ||= create_club(regular_member(1))
      get "/uni/#{club.data.filename}/#{suffix}/"
      assert_equal 200, last_response.status
    end
    
    must "render /uni/..filename../#{suffix}/ while logged in" do
      club ||= create_club(regular_member(1))
      log_in_regular_member(1)
      get "/uni/#{club.data.filename}/#{suffix}/"
      assert_equal 200, last_response.status
    end
  }

  %w{ e_chapter e_quote }.each { |mess_mod|
    must "show #{mess_mod} in Encyclopedia section" do
      club = create_club(mem)
      mess = create_message( mem, club, :message_model => mess_mod )
      get club.href_e
      assert last_response.body[mess.data.body]
    end
    
    must "not show empty message if at least one #{mess_mod} is shown" do
      club = create_club(mem)
      mess = create_message( mem, club, :message_model => mess_mod )
      get club.href_e
      assert_equal nil, last_response.body['empty_m']
    end
  }

  must "show questions in Q&A section" do
    club = create_club(mem)
    mess = create_message( mem, club, :message_model=>'question' )
    get club.href_qa
    assert last_response.body[mess.data.body]
  end
  
  must 'show magazine articles in magazine section' do
    club = create_club(mem)
    mess = create_message( mem, club, :message_model=>'mag_story')
    get club.href_magazine
    assert last_response.body[mess.data.body]
  end

  must 'show random messages in random section' do
    club = create_club(mem)
    mess = create_message( mem, club, :message_model=>'random')
    get club.href_random
    assert last_response.body[mess.data.body]
  end

  # 100.times { |i|
  #   must "#{i} do something" do
  #   get club.href_qa
  #   assert_equal "hello qa", last_response.body
  #   end
  # }
end # === class Test_Control_Clubs_Read


