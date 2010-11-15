require 'json'
require 'mongo'

require 'mongo'
# COLLS = %w{Clubs Members Member_Usernames Messages}

def ensure_no_rack_env
  if ENV['RACK_ENV']
    puts_red "RACK_ENV already defined."
    exit 1
  end
end

def compile_with_mongo_ids hsh
  case hsh
  when Array
    hsh.map { |v| compile_with_mongo_ids(v) }
  when Hash
    if hsh['$oid']
      BSON::ObjectId.from_string(hsh['$oid'])
    else
      new_hsh = {}
      hsh.each { |k, v| 
        new_hsh[k] = compile_with_mongo_ids(v)
      }
      new_hsh
    end
  else
    hsh
  end
end

# PRODUCTION_DB = File.read(File.expand_path '~/cloud.txt').strip
# DB_PRODUCTION = [ File.dirname(PRODUCTION_DB), File.basename(PRODUCTION_DB) ]
namespace :db do

  desc 'Check if MongoDB is approaching size limit.'
  task :check_size do
    
    puts_white "Checking size of MongoDB account..."
    
    require 'uri'
    url = ENV['MONGO_DB_PRODUCTION']
    uri = URI.parse( url )
    
    db_size = `mongo #{uri.host}:#{uri.port} -u #{uri.user} -p #{uri.password}  --eval "db.stats().storageSize / 1024 / 1024;" 2>&1`.strip.split.last.to_f
    if db_size > MAX_DB_SIZE_IN_MB 
      puts_red "DB Size too big: #{db_size} MB"
      exit
    else
      puts_white "DB Size is ok: #{db_size} MB"
    end
    
  end
  
  desc 'Delete all data in database.'
  task :clear! do
    # Don't use MongoDB :drop_database
    # because that erases all system/user info. 
    # for DB.

    ENV['RACK_ENV'] ||= 'development'
    if not ['development', 'test'].include?(ENV['RACK_ENV'])
      raise "Not allowed in environment: #{ENV['RACK_ENV']}" 
    end

    require 'megauni'
    Mongo_Dsl.reset_db!
    puts_white "Removed all records and added new indexes (if any)."
  end

  desc "%~ 
      Delete, then re-create database. 
      ENV['RACK_ENV'] ||= 'development'
  ".strip
  task :reset! do
    
    sh 'rake db:clear!'
    sh 'rake db:import_development'
    if ENV['RACK_ENV'] === 'test'
      sh 'rake db:test_sample_data'
    end
    
  end # ===

  desc 'Grab some sample data from production database'
  task :sample_data do
    require File.basename(File.expand_path('.'))
    
    data = JSON.parse(File.read(File.expand_path('rake/sample_data_for_dev.json')))
    
    data.each do |raw_doc|
      doc = compile_with_mongo_ids(raw_doc)
      raise ArgumentError, "No :data_model specified: #{doc.inspect}" if doc['data_model'].to_s.empty?
      DB.collection(doc['data_model']).insert(doc)
    end
    
    puts_white "Inserted sample data."
  end

  desc 'Get all data from production database and store it as a JSON file on Desktop.'
  task :save_all_docs do
    # Grab some sample data
    require 'json'
    require 'rest_client'
    base_url = 'http://miniuni:gkz260cyxk@miniuni.cloudant.com:5984/megauni_stage'
    url      = File.join( base_url, "/_all_docs")
    mess     = JSON.parse(RestClient.get(url + '?include_docs=true').body)['rows']
    
    
    processed = mess.map { |d|
      d['doc'].delete 'rev'
      d['doc'].delete '_rev'
      if d['doc']['_id'] =~ /_design/
        nil
      else
        d['doc']
      end
    }.compact

    File.open(File.expand_path('~/Desktop/all_data.json'), 'w') do |file|
      file.puts JSON.pretty_generate(processed)
    end
    
    puts_white "Finished writing data."
    
  end

  desc 'Update design document only. Uses ENV[\'RACK_ENV\']. Development by default.'
  task :reset_design_doc do
    require 'megauni'
    Mongo_Dsl.ensure_indexes
    puts_white "Updated indexes."
  end
  
  desc "Add in sample data for tests."
  task :test_sample_data do

    ENV['RACK_ENV'] = 'test'
    require 'megauni'

    # === Create Regular Member 1 ==========================
    "regular-member-1" # password: regular-password
    "regular-member-2" # password: regular-password
    "regular-member-3" # password: regular-password
    
    # === Create Admin Member ==========================
    "admin-member-1" # password: admin-password

    (1..3).to_a.each do |i|
      Member.create( 
        nil, 
        :add_username => "regular-member-#{i}", 
        :password => 'regular-password',
        :confirm_password => 'regular-password',
        :category  => 'real'
      )
    end

    doc = Member.create(
      nil, 
      :add_username => "admin-member-1",
      :password => 'admin-password',
      :confirm_password => 'admin-password',
      :category  => 'real'
    )

    doc_data = doc.data.as_hash
    doc_data['security_level'] = 'ADMIN'
    

    Member.db.collection.update(
      {'_id' =>doc_data['_id']}, 
      doc_data,
      :safe=>true
    )

    puts_white 'Inserted sample data just for tests.'
  end # ======== :db_reset!

  desc "Export the development MongoDB as a json Desktop file."
  task :export_development do
    require 'megauni'
    collections = begin
                    DB.collections.map { |doc| 
                      doc.name if doc.name =~ /\A[A-Z]/
                    }.compact
                  end
    
    collections.each { |name|
      sh "mongodump -v --db #{DB.name} --collection #{name} --out rake/sample"
    }
  end
  
  desc 'Import sample development data to MongoDB.'
  task :import_development do
    require 'megauni'
    Dir.glob("rake/sample/megauni_dev/*.bson").each { |file|
      collection = File.basename(file).sub( /\.bson\Z/, '' )
      sh("mongorestore -v --db #{DB.name} --collection #{collection} --drop #{file}")
    }
  end
  
  desc "Export the production MongoDB to development machine."
  task :export_production do
    raise "Not done: Figure out how to get list of collections."
      file_loc = File.expand_path('~/Desktop/')
      COLLS.each { |coll|
        loc = File.join(file_loc, "db_backup.#{coll}.json")
        cmd = "mongoexport -v -o #{loc} -h #{DB_HOST}:#{DB_PORT.to_s} -d #{DB_NAME} -c #{coll} -u #{DB_USER} -p #{DB_PASSWORD}"
        puts cmd
        puts `#{cmd} 2>&1`
        puts "\n"
      }
  end

  desc "Import backup files to production machine."
  task :import_production do
      file_loc = File.expand_path('~/Desktop/')
      COLLS.each { |coll|
        loc = File.join(file_loc, "db_backup.#{coll}.json")
        cmd = "mongoimport -v --drop --file #{loc} -h pearl.mongohq.com:27027/mu02 -d mu02 -c #{coll} -u #{DB_USER} -p #{DB_PASSWORD}"
        puts cmd
        puts `#{cmd} 2>&1`
        puts "\n"
      }

  end
end # === namespace :db

