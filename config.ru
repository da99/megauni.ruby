my_app_root = File.expand_path( File.dirname(__FILE__) )

if defined? Unicorn
  ENV['RACK_ENV'] = 'development'
end

begin
  raise "show maintainence page"  if File.exists?(my_app_root + '/helpers/sinatra/maintain.rb')
  require( my_app_root + '/megauni' )
rescue

  begin
    raise if Sinatra::Application.environment.to_sym === :development

    $KCODE = 'UTF8'
    require 'rubygems'
    require 'sinatra'
    require( my_app_root + '/helpers' + ['/maintain', '/sinatra/maintain'].detect { |f| File.exists?(my_app_root+'/helpers' + f + '.rb') })

    require( my_app_root + '/helpers/issue_client' )
    faux_env = {'PATH_INFO' => __FILE__.to_s, 'HTTP_USER_AGENT' => 'Rack', 'REMOTE_ADDR'=>'127.0.0.1' }
    IssueClient.create( faux_env, Sinatra::Application.environment, $!)
  rescue
    dev_env = File.expand_path('.')['home/da01'] 
    msg = dev_env ? $!.message  : ''

    before {
      halt "Error occurred. Come back later. #{msg}"
    }
  end

end

run Sinatra::Application

