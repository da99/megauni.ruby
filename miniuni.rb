$KCODE = 'u'

require 'rubygems'
require 'sinatra'
require 'sequel'
require 'pow'
require 'markaby'
require 'htmlentities'

use Rack::Session::Pool
set :session, true

configure :test do
  require Pow("~/.miniuni")
  DB = Sequel.connect ENV['TEST_DATABASE_URL']
end

configure :production do
  DB = Sequel.connect ENV['DATABASE_URL']
end

configure :development do
  require Pow("~/.miniuni")
  DB = Sequel.connect ENV['DATABASE_URL']
end

configure do
  # APP_TIME = Time.now.utc.to_s
  LOG_IN_USERNAME = 'da01'
  LOG_IN_PASS = "iluvhnkng4hkrs4vr"
  API_KEY = 'luv.4all.29bal--w0l3mg930--3'

  require Pow('models/sequel_model') 
  require Pow('models/mini_issue')  
  require Pow('models/issue')
  require Pow('models/failed_attempts')
      
  class SinatraMabWrapper
      attr_accessor :app_scope
      def method_missing(*args)
        app_scope.send(*args)
      end
      
      def respond_to?(*args)
        return false if args.include?(:builder)
        return true if app_scope.respond_to?(*args)
        false
      end  
  end # === class   
  
end # === configure


helpers do
    def remote_addr
      env['REMOTE_ADDR']
    end
    
    def using_ssl?
      env['HTTPS'] == 'on' || 
        env['HTTP_X_FORWARDED_PROTO'] =='https' || 
          env['rack.url_scheme'] == 'https' || 
            request.port == 443
    end
    
    def require_ssl!
      raise("SSL required") if !using_ssl?
    end # === def 
    
    def require_log_in!
      render_error_msg('Not logged in.')
      # redirect('/log-in') if !logged_in?
    end
    
    def logged_in?
      session[:member].is_a? String
    end # === def    
    
    def log_in(mem)
      session[:member] = mem
    end 
    
    def log_out
      session.clear
      nil
    end
    
    def authenticate?(mem, pass)
      mem ==  LOG_IN_USERNAME && pass == LOG_IN_PASS ?
        log_in(mem) :
        FailedAttempts.increase(remote_addr) && log_out ;
    end
    
    def render_error_msg(msg)
      raise "<div class='errors'>#{msg}</div>" if request.xhr?
      raise msg if request.post?
    end
    
    def render_mab(raw_file_name)
      file_name = raw_file_name.gsub(/[^a-z0-9\-\_]{1,}/i, "xxxxxxx")
      file = Pow("views/#{file_name}.mab") 
      raise "Unknow template: #{file}" if !file.file? 
      
      response['Content-Type'] = 'text/html; charset=utf-8'
      response['Accept-Charset'] = 'utf-8'   
      
      sin = SinatraMabWrapper.new
      sin.app_scope=self
      
      Markaby::Builder.new( {:mab_data=>@mab_data} , sin ) {
        instance_eval( file.read,  file.to_s, 1  )
      }.to_s                  
    end
    
end # === helpers


before do 
  require_ssl! unless ['/', '/rss.xml', '/test', '/log-out', '/favicon.ico', '/robots.txt'].include?(request.path_info)
  halt('Unknown error') if FailedAttempts.too_many?(remote_addr)
end


error do
  Issue.miniuni_error(env, options.environment)
  "Error."
end

not_found do
  Issue.miniuni_error(env, options.environment)
  "Does not exist."
end

get('/') do
  %~
    <html>
      <head>
        <title>Got no time...</title>
      </head>
      <body>
        Mega Fail.
      </body>
    </html>
  ~
end

get('/log-in') do
  require_ssl!
  render_mab('log-in')
end

get('/log-out') do
  log_out
  redirect('http://' + request.host + '/')
end

post('/log-in') do
  if authenticate?(params[:username], params[:password])
    redirect('/admin')
  else
    session[:error_msg]
    redirect('/log-in')
  end
end

get('/admin') do
  @mab_data = { :title=>'MegaUni Exceptions', 
                :issues=>Issue.filter(:resolved=>false),
                :resolved=> [], #Issue.filter(:resolved=>true),
                :mini_issues=>MiniIssue.filter(:resolved=>false)
              }
  require_log_in!
  render_mab('admin')
end

post('/error') do
  if params[:api_key] != API_KEY
    FailedAttempts.increase(remote_addr)
    halt( development? ? 'wrong api key' : 'error' ) 
  end
  
  begin
    data = (params.keys - [:api_key, 'api_key']).inject({}) { |m,k|
      m[k.to_sym] = params[k]
      m
    }
    Issue.create(data)
    "success"
  rescue
    development? ? 
      $!.message :
      Issue.miniuni_error(env, options.environment) && "error"
  end
end

get('/resolve/:id') do
  require_log_in!
  i_id = params[:id].to_i
  Issue[:id=>i_id].resolve
  redirect('/admin')
end

get('/mini/resolve/:id') do
  require_log_in!
  i_id = params[:id].to_i
  MiniIssue[:id=>i_id].resolve
  redirect('/admin')
end

get('/unresolve/:id') do
  require_log_in!
  i_id = params[:id].to_i
  Issue[:id=>i_id].unresolve
  redirect('/admin')
end

get('/rss.xml') do
  @issues = Issue.filter(:resolved=>false)
  last_issue =  [ Issue.order(:id).last, MiniIssue.order(:id).last 
                    ].compact.sort_by { |i|
                                      i.created_at.to_i 
                                  }.first 
  @last_issue_time = if last_issue 
    (last_issue.created_at || last_issue.modified_at).to_s 
  else
    'Mon Aug 17 15:20:11 UTC 2009'
  end
    
  
  response['Content-Type'] = 'application/rss+xml; charset=UTF-8'
  builder do |xml|
    xml.instruct! :xml, :version => '1.0'
    xml.rss :version => "2.0" do
      xml.channel do
        xml.title "mini uni news"
        xml.description "Wheeeee.... personal news..."
        xml.link "http://#{env['HTTP_HOST']}/"
        
        if @issues.empty?
          xml.item do
            xml.title "On Vacation."
            xml.link "http://#{env['HTTP_HOST']}/"
            xml.description "Diego has nothing on his schedule."
            xml.pubDate Time.parse(@last_issue_time).rfc822()
            # xml.guid "http://#{env['HTTP_HOST']}/#{rand(10000)}"
          end # === xml.item        
        end
        
        @issues.each do |post|
          xml.item do
            xml.title post.created_at
            xml.link "http://#{env['HTTP_HOST']}/"
            xml.description "Diego is working on website... unless he is goofing off with organic, programmable tech!"
            xml.pubDate Time.parse(post.created_at.to_s).rfc822()
            xml.guid "http://#{env['HTTP_HOST']}/#{post[:id]}"
          end # === xml.item
        end # === each
      end
    end
  end
  
end


__END__
CHECK POSTS
require 'rubygems'
require 'pow'
require '/home/da01/megauni/helpers/sinatra/post_error'

val = begin; 
  raise 'ok'; 
rescue;  
  faux_env = {'PATH_INFO' => __FILE__.to_s, 
  'HTTP_USER_AGENT' => "#<Rack::Builder:0x2ab501c36cf8 @ins=[#<Proc:0x00002ab501c68118@/usr/local/lib/ruby/gems/1.8/gems/rack-1.0.0/lib/rack/builder.rb:37>, #<Proc:0x00002ab501c68118@/usr/local/lib/ruby/gems/1.8/gems/rack-1.0.0/lib/rack/builder.rb:37>, #<Proc:0x00002ab501c68118@/usr/local/lib/ruby/gems/1.8/gems/rack-1.0.0/lib/rack/builder.rb:37>]>", 
  'REMOTE_ADDR'=>'127.0.0.1' 
}
  IssueClient.create( faux_env, :test, 'test1', 'test2'); 
end;


print val
