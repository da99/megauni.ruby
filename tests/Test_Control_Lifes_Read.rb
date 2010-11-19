# controls/Lifes.rb
require 'tests/__rack_helper__'

class Test_Control_Lifes_Read < Test::Unit::TestCase

  must 'render /uni/{some filename}/ for members' do
    log_in_regular_member(1)
    get "/life/#{regular_member(1).lifes.usernames.first}/predictions/"
    assert_equal 200, last_response.status
  end

  must 'show "This life is yours" to owner of life club' do
    msg = "This life is yours"
    mem = regular_member(3)
    un_id, un = mem.lifes._ids_to_usernames.to_a.first
    log_in_regular_member(3)
    life = Club.by_filename_or_member_username(un)
    get life.href
    assert_equal msg, last_response.body[msg]
  end

  # must 'show "This life is yours" to owner of life club' do
  #   msg = "This life is yours"
  #   mem = regular_member(3)
  #   un_id, un = mem.lifes._ids_to_usernames.to_a.first
  #   log_in_regular_member(3)
  #   life = Club.by_filename_or_member_username(un)
  #   get life.href
  #   assert_equal msg, last_response.body[msg]
  # end

  must 'allow members to post to a life club.' do
    mem = regular_member(1)
    un  = mem.lifes.usernames.first
    club = Club.by_filename_or_member_username(un)
    body = "random content #{rand(1000)} #{un}"
    
    log_in_regular_member(1)
    
    post( '/messages/', 
      "body"=>body, 
      "body_images_cache"=>"http://28.media.tumblr.com/tumblr_l414x9008E1qba70ho1_500.jpg 500 644", 
      "username"=>un, 
      "message_model"=>"random", 
      "privacy"=>"public", 
      "club_filename"=>un
    )
    
    get club.href
    assert last_response.body[body]
  end

  must 'allow members to reply to messages in a life club.' do
    mem  = regular_member(1)
    un   = mem.lifes.usernames.first
    club = Club.by_filename_or_member_username(un)
    mess = Message.find_one(:target_ids => [club.data._id])
    
    log_in_regular_member(2)
    poster = regular_member(2)
    body = "reply to #{mess['_id']} #{rand 10000}"
    
    post( '/messages/', 
      "body"=>body, 
      "username"=>poster.lifes.usernames.first, 
      "message_model"=>"cheer", 
      "privacy"=>"public", 
      'return_url' => "/mess/#{mess['_id']}/",
      "parent_message_id"=>mess['_id'].to_s
    )
    
    get "/mess/#{mess['_id']}/"
    assert last_response.body[body]
  end

end # === class Test_Control_Lifes_Read
