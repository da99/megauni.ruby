#!/home/da01/ruby-ee/bin/ruby
$KCODE = 'u' 

require File.expand_path('~/megauni/helpers/app/kernel')
require 'open3'
require 'rush'
require 'pow'
require File.expand_path('~/megauni/helpers/app/string_inflections')

module CoreFuncs
  PRIMARY_APP     = 'megauni'
  APP_NAME        = File.basename(File.expand_path('.'))
  LIFE_DIR        = Pow(File.expand_path('~/MyLife'))
  MY_PREFS        = (LIFE_DIR / "prefs")
  DESKTOP_DIR     = Pow('~/Desktop')
  BLATO_LOG       = (DESKTOP_DIR / 'blato_log.txt')
  BACKUP_DIR      = Pow('~/Dropbox/BZR_DIR')
  BZR_DIR         = ( LIFE_DIR / '.bzr' )
  MY_ERROR_LOG    = Pow('~/Desktop/errors_from_thor.txt')
  MY_EMAIL        = 'diego@miniuni.com'
  MY_NAME         = 'da01tv'
  MINIUNI_API_KEY = 'luv.4all.29bal--w0l3mg930--3'
  RAKE_HELPERS    = 'helpers/rake'
  
  private

  def development?
    File.exists?('/home/da01')
  end

  def make_symlink_or_raise(target, new_path)
    raise ArgumentError, "Target doesn not exists: #{target}" if !File.exists?(target.to_s)
    raise ArgumentError, "New path already exists: #{new_path}" if File.exists?(new_path.to_s)

    results = capture_all( "ln -s %s %s" , target, new_path)
    raise ArgumentError, results if !results.empty?
    true
  end


  def append_file( file_path, raw_txt )
    file = Pow( file_path.to_s )
    contents = ''
    if file.exists? && !file.file?
      raise "#{file} already exists and is not a file."
    end
    if file.exists?
      contents = file.read
    end
    
    file.create { |f| 
      f.puts( contents.to_s + raw_txt.to_s )
    }
  end

  def if_file_not_exists( pow_file, &blok )

    if pow_file.exists? && !pow_file.file?
      raise ArgumentError, "File name exists, but it is not a file: #{pow_file}"
    end

    if !pow_file.exists? 
      if block_given?
        return instance_eval( &blok )
      else
        raise ArgumentError, "Proc/lambda required."
      end
    end

  end
  
  # Parameters:
  #   arg_hash - Keys :to, :from. Values all Pow file objects.
  def link_file arg_hash
    require_hash_keys args_hash, :from, :to
    must_be_a_file          arg_hash[:to]
    must_be_a_symbolic_link arg_hash[:from]

    results = capture_all( "ln -s %s %s" , arg_hash[:from], arg_hash[:to])
    raise ArgumentError, results if !results.empty?
    true
  end

  def append_to_my_error_log(content)
    append_file MY_ERROR_LOG, content
  end

  def shout msg, color=:red
    say msg, :red
  end

  def whisper msg
    say msg, :white
  end

  def please_wait(msg)
    say msg + "\n", :yellow
  end


  def app_name
    File.basename( File.expand_path('.') )
  end

  def my_config(key)
    @configs ||= { 

    }
    @configs[:MY_PREFS] ||= ( @configs[:LIFE_DIR] / 'MyPrefs')
    return @configs[key] if @configs.has_key?(key)
    raise ArgumentError, "Unknown config: #{key.inspect}"
  end

  def write_file_or_raise(file, content)
    old_file = file.is_a?(Pow::File) ? file : Pow(file)
    raise ArgumentError, "#{file} already exists." if old_file.exists?
    old_file.create { |f| f.puts content }
  end

  def capture_all(*args)
    shell_capture( *args ).join("\n").strip
  end

  def shell_capture(*args)
    stem    = args.shift
    cmd     = stem % ( args.map { |s| s.to_s.inspect } )
    print_results   = args.last == :print

    Open3.popen3( cmd ) { |stdin3, stdout3, stderr3|
      [ stdout3.read, stderr3.read ].map { |s|
        s.respond_to?(:strip) ?
          s.strip :
          s
      }
    }
  end

end # === module CoreFuncs


Dir['helpers/thor/*.rb'].each do |file|
  file_name = file.sub(/\.rb$/, '')
  if file !~ /core_funcs/
    require Pow( file )
  end
end

