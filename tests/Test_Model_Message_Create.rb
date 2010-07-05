# models/Message.rb

class Test_Model_Message_Create < Test::Unit::TestCase

	def club
		Club.db_collection.find_one()
	end

	must 'be allowed to be created by member' do
    mem = Message.create(
      regular_member_1, {
        :owner_id => regular_member_1.username_ids.last,
				
        :target_ids =>  [ club['_id'] ],
        :body => 'test body',
        :emotion => 'poignant',
        :category => 'tweet',
				:privacy => 'public'
      }
    )
    assert_equal mem.data._id, Message.by_id(mem.data._id).data._id
	end
  
  must 'be created even if :target_ids is a String' do
    mem = Message.create(
      admin_member, {
        :owner_id => admin_member.username_ids.first,
				
        :target_ids => club['_id'],
        :body => 'test body',
        :emotion => 'poignant',
        :category => 'tweet',
				:privacy => 'public'
      }
    )
    assert_equal mem.data._id, Message.by_id(mem.data._id).data._id
  end
  
  must 'add Club id if :parent_message_id of message is include' do
    mess_1 = Message.create(
      regular_member_1, {
        :owner_id => regular_member_1.username_ids.last,
        :body => 'test body',
        :target_ids => [club['_id']],
        :message_model => 'random',
				:privacy => 'public'
      }
    )

    mess_2 = Message.create(
      regular_member_1, {
        :owner_id => regular_member_1.username_ids.last,
        :body => 'test body',
        :parent_message_id => mess_1.data._id,
        :message_model => 'cheer'
      }
    )
    
    assert_equal [club['_id']], mess_2.data.target_ids
  end

  must 'ignore :target_ids in raw data if :parent_message_id is set.' do
    mess_1 = Message.create(
      regular_member_1, {
        :owner_id => regular_member_1.username_ids.last,
        :body => 'test body',
        :target_ids => [club['_id']],
        :message_model => 'random',
				:privacy => 'public'
      }
    )

    mess_2 = Message.create(
      regular_member_1, {
        :owner_id => regular_member_1.username_ids.last,
        :body => 'test body',
        :parent_message_id => mess_1.data._id,
        :target_ids => '1235',
        :message_model => 'cheer'
      }
    )
    
    assert_equal [club['_id']], mess_2.data.target_ids
  end

end # === class Test_Model_Message_Create
