require 'rubygems'
require 'sinatra'
require 'sequel'
require 'pow'
require 'markaby'
require 'htmlentities'

use Rack::Session::Pool

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

  LOG_IN_USERNAME = 'da01'
  LOG_IN_PASS = "iluvhnkng4hkrs4vr"
  API_KEY = 'luv.4all.29bal--w0l3mg930--3'
  
  class FailedAttempts
    def self.fails(env)
      @fails ||= {}
      @fails[ env ] ||= 0
    end
      
    def self.increase(env)
      fails( env ) 
      @fails[env] += 1
    end

    def self.too_many?(env)
      fails(env) > 3
    end
  end # === class
  
  class MiniIssue < Sequel::Model
    def self.create(title, body)
      r = new
      coder = HTMLEntities.new
      r[:title] = coder.encode( title, :named )
      r[:body]  = coder.encode( body, :named )
      r[:created_at] = Time.now.utc
      r.save
    end
    def before_save 
      self[:created_at]= Time.now.utc
      super
    end    
    def resolve
      self[:resolved] = true
      safe_save(:changed=>true)
    end
  end
  
  class Issue < Sequel::Model
    def self.required_cols
      @required_cols ||= [ :app_name, :title,
                      :body, 
                      :environment, 
                      :path_info,
                      :user_agent, 
                      :ip_address ]
    end 
    
    def self.data_template
      required_cols.inject({}) { |m, k|
        m[k] = ''
        m
      }
    end
    def self.create(cols)
    
      valid_cols = required_cols

      invalid_cols = cols.keys - valid_cols
      raise "Hacker attempt: Invalid columns: #{invalid_cols.inspect}" if !invalid_cols.empty? 
      
      missing_cols = valid_cols - cols.keys
      raise "Missing cols: #{missing_cols.inspect}" if !missing_cols.empty?
        
      coder = HTMLEntities.new
      rec = new
      cols.each { |k,v| 
        rec[k] = coder.encode( v, :named )
        if k == :ip_address && v.is_a?(String)
          rec[k] = v.sub(/\A\:\:ffff\:/, '')
        end     
        
        if k != :body && v.is_a?(String) && v.size > 200
          rec[k] = rec[k][0,250]
        end
      }
      rec.safe_save
    end

    def safe_save(*args)
      begin
        save(*args)
      rescue
        MiniIssue.create($!.message, $!.backtrace.join("\m"))
      end
    end
        
    def before_save 
      self[:created_at]= Time.now.utc
      super
    end
    def resolve
      self[:resolved] = true
      safe_save(:changed=>true)
    end
    
    def unresolve
      self[:resolved] = false
      safe_save(:changed=>true)
    end
    
    def self.miniuni_error(env, app_env)
      data = data_template.merge({  :app_name=>'mini uni',
                                    :title=>env['sinatra.error'].message, 
                                    :path_info=>env['PATH_INFO'],
                                    :body=>env['sinatra.error'].backtrace.join("\n"),
                                    :environment=> app_env.to_s,
                                    :user_agent=> env['HTTP_USER_AGENT'].to_s,
                                    :ip_address=> env['REMOTE_ADDR']
      })
      create(data)
    end
  end # === class
  
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
  require_ssl! unless ['/', '/test', '/log-out', '/favicon.ico', '/robots.txt'].include?(request.path_info)
  halt('Unknown error') if FailedAttempts.too_many?(remote_addr)
end


error do
  Issue.miniuni_error(env, options.environment)
  "Error."
end

get('/') do
  "Mega Fail."
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
                :resolved=>Issue.filter(:resolved=>true),
                :mini_issues=>MiniIssue.all
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


