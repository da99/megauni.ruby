# controls/Hellos.rb
require 'tests/__rack_helper__' 


class Test_Control_Hellos_Mobile < Test::Unit::TestCase

  must 'sets the mobilize cookie and redirects /m/ to homepage' do
    get '/m/'
    follow_redirect!
    assert_equal '/', last_request.fullpath
    assert_equal 'yes', last_request.cookies['use_mobile_version']
  end

  must 'add a slash to the mobile homepage path: /m' do
    get '/m'
    follow_redirect!
    follow_redirect!
    assert_equal '/', last_request.fullpath
  end

  must 'redirects /salud/m/ to /salud/' do
    get '/salud/m/'
    assert_redirect '/salud/', 303
  end

  must 'redirects /help/m/ to /help/' do
    get '/help/m/' 
    assert_redirect '/help/', 303
  end

  must 'redirects the following to /salud/m/: /saludm/ /saludm/ /saludmobi/ /saludiphone/ /saludpda/' do
    %w{ /saludm/ /saludm/ /saludmobi/ /saludiphone/ /saludpda/ }.each { |url|
      get url
      follow_redirect!
      assert_equal '/salud/m/', last_request.fullpath
    }
  end

end # === class Test_Control_Hellos_Mobile
