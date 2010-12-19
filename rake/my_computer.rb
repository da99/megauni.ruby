require 'open3'
require 'models/FiDi'

MY_EMAIL = 'diego@miniuni.com'
MY_NAME = 'da01'

HOME_MY_LIFE = '~/MyLife'
MY_LIFE  = File.expand_path(HOME_MY_LIFE)
MY_PREFS = File.join(MY_LIFE, 'prefs')
DROPBOX  = File.expand_path('~/Dropbox')
BACKUP_DIR = File.join(DROPBOX, 'Backup_MyLife')
BACKUP_MY_LIFE = File.join(BACKUP_DIR, 'MyLife')

class String
  def one_line
     split("\n").map { |str| str.strip }.join(" ").strip
  end
end

def installed?(name)
    shell_out("which #{name}")[name]
end

def shell_out(*args, &blok)
    stem          = args.shift
    cmd           = stem % ( args.map { |s| s.to_s.inspect } )

    results, errors = Open3.popen3( cmd ) { |stdin3, stdout3, stderr3|
      [ stdout3.readlines, stderr3.readlines ]
    }
    
    if !errors.empty?

      if block_given?
        return blok.call(results, errors)
      end
      
      puts_red '========  Error from shell_out:  =========  '
      errors.join("\n").each { |err|
        puts_red err
      }      
      
      exit(1)
      
    end
    
    results.join(" ")
end  

namespace 'my_computer' do 

  desc 'Sets up your new computer.'
  task :setup do 

      # Create a symlink to primary app directory.
      app_alias = FiDi.directory('~/', PRIMARY_APP)
      if not File.symlink?(app_alias.path)
        puts_white "Creating sym_link: #{app_alias.path}"
        FiDi.directory(MY_LIFE, 'apps', PRIMARY_APP).create_alias( app_alias.path )
      end
 
      # Check we are not running in the backup directory.
      if File.expand_path(__FILE__)[BACKUP_MY_LIFE]
        if not File.exists?(MY_LIFE)
    puts_white "Copying #{BACKUP_MY_LIFE} to #{MY_LIFE}"
    FiDi.directory(BACKUP_MY_LIFE).copy_to(MY_LIFE) 
  end

        puts_red "Change directory to: #{app_alias.path}"
        exit
      end

      puts_white %~
         Optional: Flash fix for Ubuntu: 
         http://ubuntuforums.org/showthread.php?t=1130582&highlight=flash+problem 
      ~.one_line

      puts_white 'ruby-debug configuration file:'
      rdebug = File.join(MY_PREFS, 'ruby', 'rdebugrc.rb')
      FiDi.file(rdebug).create_alias '~/.rdebugrc'

      puts_white 'irb configuration file:'
      irbrc = File.join(MY_PREFS, 'ruby', 'irbrc.rb')
      FiDi.file(irbrc).create_alias '~/.irbrc'

      puts_white 'git configuration file:'
      gitconfig = File.join( MY_PREFS, '_gitconfig')
      FiDi.file(gitconfig).create_alias '~/.gitconfig'

      puts_white '
        Checking if hidden files are 
        displayed by default in Nautilus.
      '.one_line

      gconf = File.expand_path('~/.gconf/desktop/gnome/file_views/%gconf.xml')
      if !File.exists?(gconf) || !( File.read(gconf)['show_hidden_files'] && File.read(gconf)['show_backup_files'] )
          puts_red %~
            Always show hidden files in  Nautilus:
            http://www.watchingthenet.com/always-show-hidden-files-in-ubuntu-nautilus-file-browser.html
            Alt+F2 > gconf-editor > "desktop / gnome / file_views"
          ~
      end

      puts_white 'Creating Dropbox directory.'

      FiDi.directory(DROPBOX).mkdir
      FiDi.directory(BACKUP_DIR).mkdir

      if !shell_out('which trash')['trash']
        puts_red 'Install trash-cli.'
      end

      if !shell_out('which dropbox')['dropbox']
        puts_red 'Install DropBox.'
      end

      if shell_out('which rsync')['rsync']
        cron_task ="cd #{MY_LIFE} && #{shell_out('which rsync').strip} -av --delete #{MY_LIFE} #{BACKUP_DIR}"
        if !shell_out('crontab -l')[cron_task]
          puts_red "Setup CRONT:"
          puts_red "crontab -e"
          puts_red "59 */1 * * * #{cron_task}"
          puts_red "Don't use '--size-only' since that ignores bytes changes in files."
        end
      else
        puts_red 'Install rsync and run this task again.'
      end
      
      sysctrl_file_name = "/etc/sysctl.conf"
      sysctrl_file = File.read(sysctrl_file_name)

      if not sysctrl_file[/swappiness = (1|0)\s/]
        puts_red("From: http://lifehacker.com/333798/slim-down-and-speed-up-linux")
        puts_red("Put the following line in file: #{sysctrl_file_name}:")
        puts_red("vm.swappiness = 1")
      end

      puts_white %~
        Checking Firefox configuration...' 
        http://blogs.n1zyy.com/n1zyy/2008/09/16/firefoxs-history-setting/
      ~.one_line

      vals = {}
      vals[:"browser.history_expire_days.mirror"] = 3
      vals[:"browser.history_expire_days"]        = 3
      vals[:"browser.history_expire_sites"]       = 1000
      vals[:"network.cookie.cookieBehavior"]      = 1 # 1 = Accept cookies, except from third parties.

      vals.each do |k,v|
        if !shell_out(%!grep "#{k}" -r -r ~/.mozilla/firefox --include=prefs.js!)[/#{k}...#{v}/]
          puts_red "Change Firefox option: #{k} ===>> #{v}" 
        end
      end
      
      turn_off = []
      turn_off << %r!DivX\ {1,3}Web Player!
      turn_off << %r!The IcedTea NPR Web!

      pluginregs = Dir.glob('/home/da01/.mozilla/firefox/**/pluginreg.dat')
      if pluginregs.empty?
        puts_red %~
          You have to update the way this file checks for disabled/enabled
          plugins.
        ~
      end

      pluginregs.map { |file| 
        content = IO.read(file)
        turn_off.each do |k|
          if !content[%r!4:\$\n#{k}!]
            puts_red "Please disable Firefox plugin: #{k.inspect}"
          end
        end
      }

      plugins = [ 
          "Adblock Plus"
      ]

      plugins.each do |plug|
          results = shell_out("grep #{plug} -r ~/.mozilla/firefox --include=extensions.rdf")
          if not results[plug]
            puts_red( "Install #{plug} for Firefox" )
          end
      end

      if not shell_out('which git')['git']
        puts_red 'Install git with PPA.'
      else
        puts_white 'Git is installed.'
        results = shell_out('git config --global user.name %s' % MY_NAME.inspect)
        results += shell_out('git config --global user.email %s' % MY_EMAIL)
        if not results.strip.empty?
          puts_red( results )
        end
      end

      mongo_dir = "~/apps/mongodb"
      mongo_data = File.join(mongo_dir, 'data/db')
      mongo_log = File.join(mongo_dir, 'data/log')
      if installed?('mongod')
          puts_white "MongoDB is installed."
      else
          puts_red "Install MongoDB in #{mongo_dir}."
      end

      [ mongo_data, mongo_log].each { |dir|
          if not File.exists?(dir)
              `mkdir -p #{File.expand_path dir}`
          end
      }

      puts_white 'Linking VIM configuration file.'
      
      FiDi.file(MY_PREFS, 'vim/vimrc.vim').create_alias( '~/.vimrc' )

      puts_white 'Linking VIM dot directory.'
      FiDi.directory(MY_PREFS, 'vim', 'dotvim').create_alias '~/.vim'

      puts_white 'Creating VIM temp dir for .swp files.'
      FiDi.directory('~/.vim-temp-files').mkdir

      puts_white 'Checking .profile'
      dot_profile = File.expand_path('~/.profile')
      bashrc = File.expand_path('~/.bashrc')

      custom_bashrc = "#{HOME_MY_LIFE}/prefs/_bashrc_additions"

      [dot_profile, bashrc].each { |file|
          if not File.read(file)[File.basename(custom_bashrc)]
            puts_red %~ 
              Add the following to your #{file}:
# Custom additios for Diego
. #{custom_bashrc}
            ~
          end
      }

      require 'yaml'
      
      gemrc                   = File.join(MY_PREFS, 'ruby', 'gemrc.yaml')
      yaml                    = YAML::load(File.read(gemrc))
      bashrc_content          = File.read(File.expand_path(custom_bashrc))
      # match_in_bash_additions = bashrc_content['GEM_HOME=' + yaml["gemhome"]] &&
      #                           bashrc_content['GEM_PATH=' + yaml["gemhome"]]
      # if not match_in_bash_additions
      #   puts_red "GEM_HOME and GEM_PATH are not set properly in #{custom_bashrc}"
      # else
        FiDi.file(gemrc).create_alias '~/.gemrc'
      # end

  end # task

end # namespace

