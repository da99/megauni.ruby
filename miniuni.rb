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
  
  class FailedAttempts
    
    def self.fails
      @fails ||= 0
    end
      
    def self.increase
      fails += 1
    end

    
    def self.too_many?
      fails > 3
    end
  end # === class
  
  class Issue < Sequel::Model
    def self.required_cols
      @required_cols ||= [ :app_name, :title,
                      :body, 
                      :category, 
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

      invalid_cols = cols.keys.map {|k| k.to_sym } - valid_cols
      raise "Hacker attempt: Invalid columns: #{invalid_cols.inspect}" if !invalid_cols.empty? 
      
      missing_cols = cols.keys - valid_cols
      raise "Missing cols: #{missing_cols.inspect}" if !missing_cols.empty?
        
      coder = HTMLEntities.new
      rec = new
      cols.each { |k,v| 
        rec[k.to_sym] = coder.encode( v, :named )      
      }
      rec.save
    end
    
    def resolve
      self[:resolved] = true
      save(:changed=>true)
    end
    
    def unresolve
      self[:resolved] = false
      save(:changed=>true)
    end
    
    def self.miniuni_error(sin)
      data = data_template.merge({  :app_name=>'mini uni',
                                    :title=>env['sinatra.error'].msg, 
                                    :body=>env['sinatra.error'].backtrace.join("\n"),
                                    :category=>sin.environment.to_s,
                                    :user_agent=>sin.env['HTTP_USER_AGENT'].to_s,
                                    :ip_address=>sin.env['REMOTE_ADDR']
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
        FailedAttempts.increase && log_out ;
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
      sin.app_scope= self     
      
      Markaby::Builder.new( {:mab_data=>@mab_data} , sin ) {
        instance_eval( file.read,  file.to_s, 1  )
      }.to_s                  
    end
    
end # === helpers


before do
  require_ssl! unless ['/', '/log-out', '/favicon.ico', '/robots.txt'].include?(request.path_info)
end


error do
  Issue.miniuni_error(self)
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
                :issues=>Issue.filter(:resolved=>false)
              }
  require_log_in!
  render_mab('admin')
end

post('/error') do
  begin
    Issue.create(params)
    "success"
  rescue
    "error"
  end
end

get('/resolve/:id') do
  require_log_in!
  i_id = params[:id].to_i
  Issue[:id=>i_id].resolve
end

get('/unresolve/:id') do
  require_log_in!
  i_id = params[:id].to_i
  Issue[:id=>i_id].unresolve
end
