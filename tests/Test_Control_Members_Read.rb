# controls/Members.rb
require 'tests/__rack_helper__'

class Test_Control_Members_Read < Test::Unit::TestCase

  must "redirects to /log-in/ for non-members" do
    get '/today/', {}, ssl_hash
    follow_redirect!
    assert_equal '/log-in/', last_request.fullpath
    assert_equal 200, last_response.status
  end

  must "renders ok for members" do
    create_member_and_log_in
    get '/today/', {}, ssl_hash
    assert_equal 200, last_response.status
  end

  must "renders ok for admins" do
    log_in_admin
    get '/today/', {}, ssl_hash
    assert_equal 200, last_response.status
  end

  # must 'show a message list from followed clubs at /uni/{username}/' do
  #   
  #   content          = create_club_content
  #   club_1, club_2, rest = content[:clubs]
  #   mess_1, mess_2, rest = content[:messages]
  #   mem, uns, un_ids = add_username(regular_member_3)

  #   club_1.create_follower(mem, un_ids.first)
  #   club_2.create_follower(mem, un_ids.last)
  #   log_in_regular_member_3
  #   get "/uni/#{uns.last}/"
    # 
    # 
    # 
    # assert_equal nil, last_response.body[mess_1.data.body]
  #   assert last_response.body[mess_2.data.body]
  # end

  must 'show account: /lifes/' do
    log_in_regular_member_2
    get '/lifes/', {}, ssl_hash
    assert_last_response_ok
  end

  # ========== LIFE ============================

  must 'show profile: /life/{username}/' do
    un = regular_member_3.lifes.usernames.first
    get "/life/#{un}/"
    assert_last_response_ok
  end

  %w{ e qa news shop predictions random }.each { |suffix|
    must "show /life/{username}/#{suffix}/" do
      un = regular_member_3.lifes.usernames.first
      get "/life/#{un}/#{suffix}/"
      assert_last_response_ok
    end
  }

end # === class Test_Control_Members_Read
