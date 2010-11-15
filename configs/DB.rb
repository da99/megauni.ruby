require 'uri'

if not ENV['MONGO_DB']
  ENV['MONGO_DB'] = ENV["MONGO_DB_#{ENV['RACK_ENV']}"]
end

# === DB urls/connections ===
DB_SESSION_TABLE = 'rack_sessions'
DB_CONN          = begin
                     Mongo::Connection.from_uri( ENV['MONGO_DB'], :timeout => 3 )
                   rescue Mongo::AuthenticationError => e
                     if Uni_App.non_production?
                       puts "Did you add proper users/passwords to both dev and test databases? If not, please do."
                     end 
                     raise e
                   end
at_exit do
  DB_CONN.close
end

DB_URI = URI.parse(ENV['MONG_DB'])
DB = DB_CONN.db( File.basename( ENV['MONGO_DB'] ) )

