# controls/Messages.rb
require 'tests/__rack_helper__'

class Test_Control_Messages_Read < Test::Unit::TestCase

  must 'render /mess/4bbce6566191537a710000a4/ for anyone' do
    get "/mess/4bbce6566191537a710000a4/"
    assert_equal 200, last_response.status
  end

  must 'render a message posted to a life club' do
    mem = regular_member_2
    club = Club.by_filename_or_member_username(mem.lifes.usernames.first)
    mess = create_message(mem, club)
    get mess.href
    assert_equal 200, last_response.status
  end
  
  must 'show edit link to owner' do
    mem = regular_member_2
    club = create_club(mem)
    mess = create_message(mem, club)
    log_in_regular_member_2
    get mess.href
    assert last_response.body[mess.href_edit]
  end
  
  must 'render doc log' do
    mess = create_message(mem)
    log_in_mem
    get File.join(mess.href, '/log/')
    assert_last_response_ok
  end

end # === class Test_Control_Messages_Read
