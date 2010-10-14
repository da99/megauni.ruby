# models/Mongo_Dsl.rb

class Test_Model_Mongo_Dsl_Indexes < Test::Unit::TestCase

  must 'have an index for Failed_Log_In_Attempts: date, ip_address, owner_id' do
    target = {
    "key"  => {"date" =>-1, "ip_address" =>-1, "owner_id" =>1},
    "ns"   => "megauni_test.Failed_Log_In_Attempts",
    'background' => true,
    'unique'     => false,
    "name" => "date_-1_ip_address_-1_owner_id_1"
    }
  
    result = DB.collection(Failed_Log_In_Attempt.db.collection.name).
              index_information['date_-1_ip_address_-1_owner_id_1']
    
    assert_equal target, result
  end

  must 'drop, insert an index if :background value changed' do
  end

end # === class Test_Model_Mongo_Dsl_Indexes
