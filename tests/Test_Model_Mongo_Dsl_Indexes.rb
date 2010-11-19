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

  must 'allow set :background option to true' do
    name       = 'Jobs'
    coll       = DB.collection(name)
    index_name = 'name_1'
    if coll.index_information[ index_name ]
      coll.drop_index index_name
    end

    Mongo_Dsl.update_indexes( Mongo_Dsl::Db_Indexer.new.collection( name ) {
      asc :name
    })
    
    assert_equal true, coll.index_information[index_name]['background']
  end
  must 'allow unique indexes' do
    name       = 'Lifers'
    coll       = DB.collection(name)
    index_name = 'username_1'
    if coll.index_information[ index_name ]
      coll.drop_index index_name
    end

    Mongo_Dsl.update_indexes( Mongo_Dsl::Db_Indexer.new.collection( name ) {
      unique
      asc :username
    })
    
    assert_equal true, coll.index_information[index_name]['unique']
  end

  must 'drop/insert an index if :background value changed' do
    name       = 'Cafes_On_The_Block'
    index_name = 'date_1_name_-1'
    bg         = lambda {
      DB.collection(name).index_information[index_name]['background']
    }
    
    DB.collection(name).drop_index index_name
    
    DB.collection(name).create_index(
      [['date', Mongo::ASCENDING], ['name', Mongo::DESCENDING]], 
      'background' => false,
      'unique' => false
    )
    
    assert_equal false, bg.call
    
    Mongo_Dsl.update_indexes Mongo_Dsl::Db_Indexer.new.collection( name ) {
      asc :date
      desc :name
    }
    
    assert_equal true, bg.call
  end
  

  must 'drop/insert an index if :unique value changed' do
    name       = 'Cafes_On_The_Block'
    index_name = 'date_1_name_-1'
    opt_unique = lambda {
      DB.collection(name).index_information[index_name]['unique']
    }
    
    DB.collection(name).drop_index index_name
    
    DB.collection(name).create_index(
      [['date', Mongo::ASCENDING], ['name', Mongo::DESCENDING]], 
      'background' => false,
      'unique' => false
    )
    
    assert_equal false, opt_unique.call
    
    Mongo_Dsl.update_indexes( Mongo_Dsl::Db_Indexer.new.collection( name ) {
      asc :date
      desc :name
      unique
    } )
    
    assert_equal true, opt_unique.call
  end

end # === class Test_Model_Mongo_Dsl_Indexes
