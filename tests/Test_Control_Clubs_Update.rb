# controls/Clubs.rb
require 'tests/__rack_helper__'

class Test_Control_Clubs_Update < Test::Unit::TestCase

  def create_club(mem)
    id = rand(20000)
    club = Club.create(mem, :filename=>"#{id}", :title=>"Club: #{id}", 
                       :teaser=>"Teaser for: Club #{id}. Created by: #{mem.usernames.first}"
                      )
  end
  
  must 'not allow strangers' do
    put "/clubs/hearts/", :title=>'new-hearts'
    follow_redirect!
    assert_equal '/log-in/', last_request.fullpath
  end

  must 'not allow non-owners' do
    club = create_club(regular_member_1)
    log_in_regular_member_2
    err = assert_raise(Couch_Plastic::Unauthorized) do
      put club.href, :title=>'new-hearts'
    end

    assert_match( /\AUpdator: /, err.message )
  end

  must 'allow Admins' do
    club = create_club(admin_member)
    log_in_admin
    put club.href, :title=>'new-hearts'
    follow_redirect!
    assert_match(%r!<title>new-hearts</title>!, last_response.body)
  end

  must 'allow club owners' do
    club = create_club(regular_member_1)
    log_in_regular_member_1
    put club.href, :title=>'new-club-1'
    follow_redirect!
    assert_match( %r!<title>new-club-1</title>!, last_response.body )
  end

end # === class Test_Control_Clubs_Update