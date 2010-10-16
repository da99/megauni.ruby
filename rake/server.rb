require 'rush'

def db_running?
  !!(Rush.processes.filter(:cmdline=>/mongod\ /).to_a.size > 0)
end

namespace :server do
  
  desc 'SSH into WebFaction account'
  task :ssh do
    exec('ssh da01@174.121.79.154')
  end

  desc 'Start the server.'
  task :http do
    sh 'rake server:db' unless db_running?
    exec "thin -p 4567 -R config.ru -t 5 start"
  end

  desc 'Start Shotgun.
    shotgun --server=thin --port=4567 --public /no_public config.ru
  '
  task :shotgun do
    sh 'rake server:db' unless db_running?
    exec "shotgun --server=thin --port=4567 --public /no_public config.ru"
  end

  task :nginx do
    it 'Starts up Nginx, after invoking nginx_stop.'
    steps {
      require 'rush'
      if Rush.processes.filter(:cmdline=>/nginx/).size > 0
        puts_red 'Shutdown nginx first.'
        exit(1)
      end
      exec 'sudo /etc/init.d/nginx start'
    }
  end

  task :nginx_stop do
    it 'Stops Nginx.'
    steps {
      exec 'sudo /etc/init.d/nginx stop'
    }
  end

  # These use 'exec', which replaces the current process (i.e. Rake)
  # More info: http://blog.jayfields.com/2006/06/ruby-kernel-system-exec-and-x.html
  task :light do
    it "Runs the lighttpd server. (Uses :exec to replace current process.)"
    steps {
      require 'rush'
      if Rush.processes.filter(:cmdline=>/lighttpd/).size > 0
        puts_red 'Shutdown lighttpd first.'
        exit(1)
      end
      exec "sudo /etc/init.d/lighttpd start"
    }
  end

  task :dev do
    it "Runs Unicorn in :development mode. (Uses :exec.)"
    steps {
      fefe_run 'sass:delete'
      exec "unicorn -p 4999"
    }
  end

  desc "Sends HUP signal to Unicorn master, which will restart all workers."
  task :reload do
    puts_white 'Restarting...'
    require 'rush'
    Rush.processes.filter(:cmdline=>/unicorn master/).each { |process|
      puts_white "Sending HUP signal to unicorn master pid: #{process.pid}"
      Process.kill('HUP', process.pid)
    }
    puts_white 'Done.'
    true
  end

  desc 'Start MongoDB server.'
  task :db do 
    dir = "~/apps/mongodb"
    
    if not db_running?
      exec("mongod --dbpath #{dir}/data/db --fork --logpath #{dir}/data/log/log.txt ")
    else
      puts_white "Mongodb already running."
    end
    
  end

  desc 'Start Mongo shell.'
  task :mongo do
    exec("~/Desktop/mongodb/bin/mongo")
  end
  
  desc 'Shutdown background MongoDB server process.'
  task :shutdown_db do
    Rush.processes.filter(:cmdline=>/mongod\ /).kill.inspect
    puts_white 'All mongodb processes have been killed.'
    
  end
  
  desc 'Open CouchDB Futon in the Browser'
  task :futon do
    Launchy.open 'http://127.0.0.1:5984/_utils/index.html'
  end

  desc 'Install crontab for production.'
  task :install_crontab do
    puts_white %!
*/15 * * * * cd /home/da01 && export LD_INCLUDE_PATH=/home/da01/include/smjs:/home/da01/include/layout:/home/da01/include/unicode:$LD_INCLUDE_PATH && export LD_LIBRARY_PATH=/home/da01/lib:$LD_LIBRARY_PATH &&  /home/da01/bin/couchdb -b
*/16 * * * * cd /home/da01/megauni && /home/da01/.gem/ruby/1.8/bin/unicorn -p 34735 -E production -D
*/15 * * * * cd /home/da01/my_apps/mongodb && ./bin/mongod --dbpath data/db --port 27017 --fork --logpath data/log.txt
    !
  end

end # === namespace :server

namespace :unicorn do

  desc 'Start unicorn. Uses RACK_ENV (default: development)'
  task :start do
    ENV['RACK_ENV'] ||= 'development'
    puts 'Starting unicorn...'
    exec("unicorn -p 34735 -E #{ENV['RACK_ENV']} -D")
  end

  desc 'Stopping unicorn'
  task :stop do
    exec(%~ruby -e "require 'rubygems'; require 'rush'; Rush.processes.filter(:cmdline=>/unicorn/).kill"~)
    # puts 'Stopping unicorn...'
    # require 'rush'
    # Rush.processes.filter(:cmdline=>/unicorn/).kill
    # puts "Unicorns have stopped."
  end
  
  desc 'Restart unicorns. (Kills worker processes, not the master process).'
  task :restart do
    unicorn_off = !`ps x`[/unicorn master -/]
    if unicorn_off
      Rake::Task['unicorn:start'].invoke
    else
      puts 'Restarting unicorn...'
      require 'rush'
      old_master = Rush.processes.filter(:cmdline=>/unicorn master/).first
      Process.kill('HUP', old_master.pid)
      
      # The following isn't working on the server.
      # It shutdowns Unicorn, but won't restart the new process.
      # Process.kill('USR2', old_master.pid)
      # Process.kill('WINCH', old_master.pid)
      # Process.kill('QUIT', old_master.pid)
      puts 'Done.'
    end
  end

end

