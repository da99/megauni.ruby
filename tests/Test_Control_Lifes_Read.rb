# controls/Lifes.rb
require 'tests/__rack_helper__'

class Test_Control_Lifes_Read < Test::Unit::TestCase

  must 'show "This life is yours" to owner of life club' do
    msg = "This life is yours"
    mem = regular_member(3)
    un_id, un = mem.lifes._ids_to_usernames.to_a.first
    log_in_regular_member(3)
    life = Club.by_filename_or_member_username(un)
    get life.href
    assert_equal msg, last_response.body[msg]
	end

end # === class Test_Control_Lifes_Read
