# controls/Clubs.rb
# models/Club.rb

require 'tests/__rack_helper__'

class Test_Control_Clubs_Create < Test::Unit::TestCase

  def rand_club
    num = rand(2000)
    {:filename=>"swsw-#{num}", :title=>"SWSW #{num}", :teaser=>"A teaser for SWSW #{num}"}
  end

  must 'allow any member to create a Club' do
    log_in_member
    club = rand_club
    post '/clubs/', club
    follow_redirect!
    assert_equal "/clubs/#{club[:filename]}/", last_request.fullpath
  end

  must 'not allow a non-member to create a Club' do
    club = rand_club
    post '/clubs/', club
    follow_redirect!
    assert_equal "/log-in/", last_request.fullpath
  end


end # === class Test_Control_Clubs_Create