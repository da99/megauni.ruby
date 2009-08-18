require 'rubygems'
require "highline/import"
require 'pow'

def dev?
  !ENV.keys.include?('HEROKU_ENV') && ENV.keys.include?('DESKTOP_SESSION')
end

def print_this(*args)
  args.each {|new_line|
    if new_line.empty?
      print "\n"
    else
      print "===>  #{new_line}\n\n" 
    end
  }
end

print_this ''

def exec_this(command)
  `#{command} 2>&1`
end

def raise_this( error_str )
  print_this '', error_str, ''
  raise
end


namespace :db do
  task :connect do
    require 'sequel'
    require 'sequel/extensions/migration'     
    require(Pow('~/.miniuni')) if Pow('~/.miniuni.rb').file?
    DB = Sequel.connect ENV['DATABASE_URL']
  end
end

namespace :production do
  task :up do
		print_this "Migrating..."
		Rake::Task['db:connect'].invoke
		Sequel::Migrator.apply( DB, Pow('migrations') )
		print_this "Done."	
  end
end

namespace :migrate do
  desc "Migrate to latest version."
  task :up do
		print_this "Migrating..."
		Rake::Task['db:connect'].invoke
		Sequel::Migrator.apply( DB, Pow!('migrations') )
		print_this "Done."	
  end
  
  desc 'Migrate to version 0'
  task :down do
    raise ArgumentError, "This task not allowed in :production" unless dev?

    print_this "Reseting database..."
    Rake::Task['db:connect'].invoke

    Sequel::Migrator.apply( DB, Pow!('migrations'), 0 )
    print_this "Done."
  end
  
  desc 'Migrate to a specific version.'
  task :specify do
    raise ArgumentError, "This task not allowed in :production" unless dev?

    Rake::Task['migrate:down'].invoke

    Sequel::Migrator.apply( DB, Pow!('migrations'), ask('Specify version:').to_i )
    print_this "Done."
  end
end # === namespace

namespace :git do

  desc "Execute: git add . && git add -u && git status"
  task :update do
    results = `git add . && git add -u && git status`
    print_this results
  end

  desc "Gathers comment and commits it using: git commit -m '[your input]' "
  task :commit do
    Rake::Task['git:update'].invoke
    new_comment = ask('Enter comment (type "E" to end it):') { |q|
      q.gather = 'E'
    }
    results = `git commit -m '#{new_comment.join("\n").gsub("'", "\\\\'")}'`
    print_this ''
    print_this results
  end
  
  task :status do
    print_this `git status`
  end
  
  desc "Used to update and commit development checkpoint. Includes the commit comment for you."
  task :dev_check do
    Rake::Task['git:update'].invoke
    commit_results = `git commit -m "Development checkpoint."`
    print_this ''
    print_this commit_results
  end
  
  task :push do
    status_results = `rake git:status 2>&1`
    if status_results['nothing to commit']
      print_this 'Please wait as code is being pushed to Heroku...'
      push_results = `git push heroku master 2>&1`
      print_this push_results
      `heroku open`
    else
      raise_this "Uncommited code: \n\n #{status_results}"
    end
  end
  
  task :push_and_migrate do
    Rake::Task['git:push'].invoke
    
    print_this 'Migrating on Heroku...'
    migrate_results = `heroku rake migrate:up`
    raise "Problem on executing migrate:up on Heroku." if migrate_results['aborted']
    print_this migrate_results
    
    print_this 'Restarting app servers.'
    print_this `heroku restart`
  end

end # ==== namespace :git


namespace :run do
  # These use 'exec', which replaces the current process (i.e. Rake)
  # More info: http://blog.jayfields.com/2006/06/ruby-kernel-system-exec-and-x.html
  task :light do
    exec "sudo /etc/init.d/lighttpd start"
  end

  task :dev do
    exec  "thin start --rackup config.ru -p 4567"
  end
  
  task :tests do
    exec 'DATABASE_URL=postgres://da01:xd19yzxkrp10@localhost/newsprint-db-test'
  end

end


namespace :migration do

	desc "Create a migration file. Tip: You can use model:create to automatically create migration."
	task( :create ) do

    # Require Sequel in order to use :camelize method
    require 'sequel/extensions/inflector'
    m = ask('Name of migration:').strip.camelize.pluralize
    i = Dir.entries('./migrations').select {|f| f=~ /^\d\d\d\_\w{1,}/}.sort.last.to_i + 1
    padding = '0' * (3 - i.to_s.length)
    file_path = Pow!("migrations/#{padding}#{i}_#{m.underscore}.rb")
    raise ArgumentError, "File: #{file_path} already exists." if File.exists?(file_path )

    txt = <<-EOF
class #{m}_#{i} < Sequel::Migration

  def up  
    create_table( :#{m.underscore} ) {
      # === Associations
      primary_key :id
      
      
      # === Attributes
      
      
      # === Date Times
      timestamp   :created_at
      timestamp   :modified_at, :null=>true
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:#{m.underscore}) if table_exists?(:#{m.underscore})
  end

end # === end Create#{m}
EOF

    file_path.create { |f|
      f.puts txt
    }
	end # === task :create_migration => "__setup__:env"

end # === namespace :migration
