# controls/Hellos.rb


describe :Control_Hellos_Mobile do

  it 'sets the mobilize cookie and redirects /m/ to homepage' do
    get '/m/'
    follow_redirect!
    assert_equal '/', last_request.fullpath
    assert_equal 'yes', last_request.cookies['use_mobile_version']
  end

  it 'add a slash to the mobile homepage path: /m' do
    get '/m'
    follow_redirect!
    follow_redirect!
    assert_equal '/', last_request.fullpath
  end

  it 'redirects /salud/m/ to /salud/' do
    get '/salud/m/'
    assert_redirect '/salud/', 303
  end

  it 'redirects /help/m/ to /help/' do
    get '/help/m/' 
    assert_redirect '/help/', 303
  end

  it 'redirects the following to /salud/m/: /saludm/ /saludm/ /saludmobi/ /saludiphone/ /saludpda/' do
    %w{ /saludm/ /saludm/ /saludmobi/ /saludiphone/ /saludpda/ }.each { |url|
      get url
      follow_redirect!
      assert_equal '/salud/m/', last_request.fullpath
    }
  end

end # === class Test_Control_Hellos_Mobile
