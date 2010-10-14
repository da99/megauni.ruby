
# === DB urls/connections ===
DB_CONN = if Uni_App.production?
            DB_NAME          = "mu02"
            DB_HOST          = "pearl.mongohq.com:27027/#{DB_NAME}"
            DB_USER          = 'da01'
            DB_PASSWORD      = "isle569vxwo103"
            DB_CONN_STRING   = "#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}"
            MONGODB_CONN_STRING ="mongodb://#{DB_CONN_STRING}"
            DB_SESSION_TABLE = 'rack_sessions'
            Mongo::Connection.from_uri(
              MONGODB_CONN_STRING,
              :timeout=>3
            ) 
          else
            case Uni_App.environment
            when :development
              DB_NAME = "megauni_dev"
            when :test
              DB_NAME = "megauni_test"
            else 
              raise "Unknown environment: #{Uni_App.environment.inspect}"
            end
            DB_HOST          = "localhost:27017/#{DB_NAME}"
            DB_USER          = 'da01'
            DB_PASSWORD      = "kgflw30zeno4vr"
            DB_CONN_STRING   = "#{DB_USER}:#{DB_PASSWORD}@#{DB_HOST}"
            MONGODB_CONN_STRING = "mongodb://#{DB_CONN_STRING}"
            DB_SESSION_TABLE = 'rack_sessions'
            begin
              Mongo::Connection.from_uri(MONGODB_CONN_STRING, :timeout=>1)
            rescue Mongo::AuthenticationError 
              puts "Did you add #{DB_USER} to both dev and test databases? If not, please do."
              raise
            end
          end

at_exit do
  DB_CONN.close
end
  

DB = case Uni_App.environment
  
  when :test
    DB_CONN.db("megauni_test")
    
  when :development
    DB_CONN.db("megauni_dev")

  when :production
    DB_CONN.db(DB_NAME)

  else
    raise ArgumentError, "Unknown RACK_ENV value: #{ENV['RACK_ENV'].inspect}"

end # === case

