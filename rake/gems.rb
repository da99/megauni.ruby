# The following constants only need to be created when gem namespace is used.

PRIMARY_APP = 'megauni'


if Rake.application.top_level_tasks.detect { |t| t['gem:'] }
  GEM_MANIFEST           = File.expand_path(File.join('~/', PRIMARY_APP, '.gems'))
  GEM_MANIFEST_ARRAY     = File.read(GEM_MANIFEST).strip.split("\n")
  GEM_PRODUCTION_PAIR    = [GEM_MANIFEST, GEM_MANIFEST_ARRAY]

  GEM_MANIFEST_DEV       = GEM_MANIFEST.sub('.gems', '.development_gems')
  GEM_MANIFEST_DEV_ARRAY = File.read(GEM_MANIFEST_DEV).strip.split("\n")
  GEM_DEVELOPMENT_PAIR   = [GEM_MANIFEST_DEV, GEM_MANIFEST_DEV_ARRAY]
end

namespace :gem do 
    
  desc 'Installs a gem for the development environment. Uses ENV["cmd"]'
  task :development_install do
    ENV['env'] = 'development'
    Rake::Task['gem:install'].invoke
  end

  
  desc 'It install a gem for the production environment. Uses ENV["cmd"]'
  task :production_install do
    ENV['env'] = 'production'
    Rake::Task['gem:install'].invoke
  end

    
  desc "Install a gem and update appropriate gem manifest. Uses ENV['cmd'] and ENV['env']"
  task :install do
    
    cmd = ENV['cmd']
    env = ENV['env']
    
    raise "Invalid environment: #{cmd}" unless %w{production development}.include?(env)
    
    command = assert_not_empty(cmd)

    puts_white "Installing: #{command}"

    sh "gem install --no-ri --no-rdoc --backtrace #{command}"

    file , arr = eval("GEM_#{env.upcase}_PAIR")

    gem_name = command.strip.split.first
    new_arr = arr.reject { |g| g.strip.split.first.upcase == gem_name.upcase } 
    new_arr << command
    File.open(file, 'w') { |f|
      f.write new_arr.join("\n")
    }

  end

    
  desc 'Uninstalls a gem in the .development_gems file using ENV["cmd"].'
  task :development_uninstall do
    ENV['env'] = 'development'
    Rake::Task['gem:uninstall'].invoke
  end

    
  desc 'Uninstalls a gem in the .production_gems file.'
  task :production_uninstall do
    ENV['env'] = 'production'
    Rake::Task['gem:uninstall'].invoke
  end

    
  desc "Uninstalls and updates .gems and .development_gems."
  task :uninstall do

    cmd = ENV['cmd'].to_s.strip
    raise ArgumentError, "cmd can't be empty" if cmd.empty?
    gem_name = cmd.split.first
    puts_white "Uninstalling: #{gem_name}"

    # It's magic time... Uninstall gem, don't use
    # anything other than :system, to retain 'gem uninstall'
    # interactivity, especially during questioning of 
    # gem dependencies.
    if `gem list`[gem_name]
      sh "gem uninstall #{cmd} -a -x -V --backtrace "
    end

    %w{development production}.each { |env|
      file, arr = eval("GEM_#{env.upcase}_PAIR")

      File.open( file, 'w' ) do |f|
        f.write arr.reject { |l| 
          l.strip.split.first == gem_name
        }.join("\n")
      end
    }

  end

  
  desc "Installs and updates all gems from manifests.
  (.gems, .development_gems).
  Use PRODUCTION=true to limit to just .gems.
  Creates .update_gems for rake git:push.
  " 
  task :update  do

    # Figure out what gems to install.
    gems_to_install = GEM_MANIFEST_ARRAY 
    unless ENV['RACK_ENV']=='production'
      gems_to_install += GEM_MANIFEST_DEV_ARRAY
    end

    installed = `gem list`
    if gems_to_install.empty?
      puts_white  "No gems to install."
    else
      gems_to_install.each { |g|
        gem_name = g.split.first.strip
        if gem_name[/^[a-z0-9]/i] # Starts w/ alpha-numeric character ???
          if installed["#{gem_name} ("]
            puts_white "Already installed: #{gem_name}"
          else
            sh( "gem install #{gem_name}" )
          end
        end
      }
    end    

    # We need to tell Heroku to update gems
    #   by altering .gems manifest.
    # Appending a single line is enough.
    # 
    File.open('.gems', 'a') { |f|
      f.puts "\n"
    }
    
    # Now to update all gems on this
    #   development machine.
    sh('gem update') 
  end   
  
  desc "Uninstalls all gems, then installs all gems from .gems and .development_gems."
  task :reinstall_everything do
    
    # Command from: http://geekystuff.net/2009/1/14/remove-all-ruby-gems
    puts `gem list | cut -d" " -f1 | xargs gem uninstall -aIx`
    
    gems = File.read('.gems') + File.read('.development_gems')
    gems.split("\n").each { |cmdl| puts `gem install #{cmdl}` }
  end
     
end # === namespace :gem
