# controls/Clubs.rb
require 'tests/__rack_helper__'

class Test_Control_Clubs_Read < Test::Unit::TestCase

  def mem
    regular_member_1
  end

  must 'render /uni/' do
    get '/uni/'
    assert_last_response_ok
  end

  must 'render /uni/ for members' do
    log_in_regular_member_1
    get '/uni/'
    assert_last_response_ok
  end

  must 'be viewable by non-members' do
    club = create_club
    get "/uni/#{club.data.filename}/"
    
    assert_match(/#{club.data.title}/, last_response.body)
  end

  must 'render /uni/{some filename}/ for members' do
    log_in_regular_member_1
    get '/uni/predictions/'
    assert_equal 200, last_response.status
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

  must 'present a create message form for logged-in members' do
    club = create_club
    
    log_in_regular_member_1
    get club.href_e
    form = Nokogiri::HTML(last_response.body).css('form#form_club_message_create').first
    
    assert_equal Nokogiri::XML::Element, form.class
  end

  must 'include club filename for :club_filename in message create form' do
    club = create_club
    
    log_in_regular_member_1
    get club.href_e
    target_ids = Nokogiri.HTML(last_response.body).css(
      'form#form_club_message_create input[name=club_filename]'
    ).first
    
    assert_equal club.data.filename.to_s, target_ids.attributes['value'].value
  end

  must 'include member\'s username for :username in message create form' do
    club = create_club
    
    log_in_regular_member_1
    get club.href_e
    un = Nokogiri.HTML(last_response.body).css(
      'form#form_club_message_create input[name=username]'
    ).first
    
    assert_equal regular_member_1.lifes.usernames.first, un.attributes['value'].value
  end

  must 'not show follow club link to strangers.' do
    club = create_club
    get club.href
    
    assert_equal nil, last_response.body[club.href_follow]
  end

  must 'not show follow club link to club creator' do
    club = create_club(regular_member_1)

    log_in_regular_member_1
    get club.href
    assert_equal nil, last_response.body[club.href_follow]
  end

  must 'not show "You are following" message to club creator' do
    club = create_club(regular_member_1)

    log_in_regular_member_1
    get club.href
    assert_equal nil, last_response.body['following']
  end

  must 'not show follow club link to followers.' do
    club = create_club(regular_member_1)
    club.create_follower( regular_member_2, regular_member_2.lifes._ids.first )

    log_in_regular_member_2
    get club.href

    assert_not_equal club.href_follow, last_response.body[club.href_follow]
  end

  must 'show follow club link to members.' do
    club = create_club(regular_member_1)

    log_in_regular_member_2
    get club.href
    
    assert_equal club.href_follow, last_response.body[club.href_follow]
  end

  must 'allow members to follow someone else\'s club' do
    club = create_club(regular_member_2)

    log_in_regular_member_1
    get File.join('/', club.href, 'follow/')
    follows = Club.find_followers(
      :club_id=>club.data._id, 
      :follower_id=>regular_member_1.lifes._ids.first
    ).to_a

    assert_equal 1, follows.size
  end

  must 'show a form if user has multiple usernames' do
    if regular_member_3.lifes.usernames.size == 1
      Member.update(
        regular_member_3.data._id, 
        regular_member_3, 
        :add_username=>"username-#{rand(2000)}"
      )
    end

    club = create_club(regular_member_1)
    log_in_regular_member_3
    get club.href

    assert Nokogiri::HTML(last_response.body).css('form#form_follow_create').first
  end

  # ================ Life Club ===========================

  must 'use /uni/{filename}/ for life clubs' do
    mem   = regular_member_1
    un_id, un  = mem.lifes._ids_to_usernames.to_a.first
    life  = Club.by_filename_or_member_username(un)
    assert_equal "/uni/#{un}/", life.href
  end

  must 'show "This life is yours" to owner of life club' do
    msg = "This life is yours"
    mem = regular_member_3
    un_id, un = mem.lifes._ids_to_usernames.to_a.first
    log_in_regular_member_3
    life = Club.by_filename_or_member_username(un)
    get life.href
    assert_equal msg, last_response.body[msg]
  end

  # ================ Club Search ===========================

  must 'redirect to /club-search/{filename}/ if more no club found' do
    keyword = 'factor' + rand(1000).to_s
    post "/club-search/", :keyword=>keyword
    follow_redirect!
    assert_equal "/club-search/#{keyword}/", last_request.path_info
  end

  must 'CGI.escape the filename in /club-search/{filename}/' do
    keyword = 'factor@factor' + rand(10000).to_s
    post "/club-search/", :keyword=>keyword
    follow_redirect!
    escaped = CGI.escape(keyword)
    assert_equal "/club-search/#{escaped}/", last_request.path_info
  end

  must 'redirect to club profile page if only one club found' do
    club = create_club(regular_member_1, :filename=>"sf_#{rand(10000)}")
    post "/club-search/", :keyword=>club.data.filename
    follow_redirect!
    assert_equal "/uni/#{club.data.filename}/", last_request.fullpath
  end

  must 'redirect to life club if keyword is a member username' do
    un = regular_member_1.lifes.usernames.first
    post "/club-search/", :keyword=>un
    assert_redirect "/uni/#{un}/", 303
  end

  # ================= Club Parts ===========================

  %w{ e  qa news magazine fights shop predictions random thanks }.each { |suffix|
    club = nil
    
    must "render /uni/..filename../#{suffix}/" do
      club ||= create_club(regular_member_1)
      get "/uni/#{club.data.filename}/#{suffix}/"
      assert_equal 200, last_response.status
    end
    
    must "render /uni/..filename../#{suffix}/ while logged in" do
      club ||= create_club(regular_member_1)
      log_in_regular_member_1
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


  must 'show questions in Q&A section' do
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

end # === class Test_Control_Clubs_Read
