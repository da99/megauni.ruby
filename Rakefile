
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
  
  task :push_and_dont_open do
    status_results = `rake git:status 2>&1`
    if status_results['nothing to commit']
      print_this 'Please wait as code is being pushed to Heroku...'
      push_results = `git push heroku master 2>&1`
      print_this push_results
    else
      print_this status_results, "You can *not* push this code. <<<<<<<<<<<<<<<<<<<"
      raise_this "Before you can push, you must commit. <<<<<<<<<<<"
    end
  end  
  
  task :push do
    Rake::Task['git:push_and_dont_open'].invoke
    `heroku open`
  end
  
  task :push_and_migrate do
    Rake::Task['git:push_and_dont_open'].invoke
    
    print_this 'Migrating on Heroku...'
    migrate_results = `heroku rake migrate:up`
    raise "Problem on executing migrate:up on Heroku." if migrate_results[/aborted/i]
    print_this migrate_results
    
    print_this 'Restarting app servers.'
    print_this `heroku restart`
    `heroku open`
  end

end # ==== namespace :git





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
