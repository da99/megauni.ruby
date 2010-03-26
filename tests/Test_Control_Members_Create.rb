# controls/Members.rb
require 'tests/__rack_helper__'

class Test_Control_Members_Create < Test::Unit::TestCase

  must 'redirects and shows password errors' do 
    post '/member/', {:add_life=>'friend', :add_life_username=>'da01111' + rand(10000).to_s, :password=>'pw'}, ssl_hash
    follow_redirect!
    assert_match(/Password must be at least 5 characters long/, last_response.body)
  end

  must 'redirects and shows username errors' do
    post '/member/', {:add_life=>'friend', :add_life_username=>'d', :password=>'myuni4vr', :confirm_password=>'myuni4vr'}, ssl_hash
    follow_redirect!
    assert_match(
      /Username is too small. It must be at least 2 characters long/, 
      last_response.body 
    )
  end

  must 'redirects and shows username uniqueness errors' do
    vals = { :password=>'myuni4vr', 
             :confirm_password=>'myuni4vr', 
             :add_life=>'friend', 
             :add_life_username=>'admin-member-1'}
    post '/member/', vals, ssl_hash
    follow_redirect!
    assert_match( /Username already taken\: admin\-member/, last_response.body )
  end

  must( 'does not create itself + username if username is already taken.' ) do
		
		u_name = "da01-#{Time.now.to_i}"
    begin
			Member.create(nil, { 
					:password=>'test123test',
					:confirm_password => 'test123test',
					:add_life_username => u_name,
					:add_life => 'friend'
			})
    rescue Member::Invalid
      assert_match( /^Username is already taken/i, $!.message.to_s )
    end
    
		err = begin
			Member.by_username(u_name)
		rescue Couch_Doc::Not_Found
			'not_found'
		end

		assert_equal err, 'not_found'
		
  end
  

end # === class Test_Control_Members_Create