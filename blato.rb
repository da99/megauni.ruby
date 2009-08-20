#!/home/da01/rubyee/bin/ruby

require 'rubygems'
require 'sequel/extensions/inflector'
require 'pow'
require 'highline'
require 'stringio' 

module Blato
  def self.blato_classes
    @blato_classes ||= []
  end
  
  def self.blato_objects
    @blato_objects ||= []
  end
  
  def self.blato_tasks
    @blato_tasks ||=[]
  end
  
  def self.blato_task_properties
    @blato_task_properties ||= {}
  end
  
  def self.invoked_tasks
    @invoked_tasks ||=[]
  end
  
  def self.development?
    Pow("~/Dropbox").exists? || Pow("/home/da01/megauni").exists?
  end

  def self.production?
    !ENV.keys.include?('DESKTOP_SESSION') &&
     ( !development? || 
          ENV.keys.include?('HEROKU_ENV')  
     )
  end  
  
  def self.included(klass)
    blato_classes << klass
    klass.extend ClassMethods
  end
  
  def self.check_for_errors
    blato_tasks.each { |task| 
      underscored, meth = task.split(':').map { |s| s.strip }
      oClass = eval underscored.camelize
      if !oClass.method_defined?("__#{meth}")
        raise "#{oClass}:#meth} does not exist." 
      end
    }
  end
  
  def self.get_blato_class(raw_name)
    name = raw_name.to_s.underscore
    return nil if blato_tasks.include?(name)
    eval("#{raw_name.to_s.camelize}")
  end
  
  
  def self.invoke(cmd, *opts)
    instance = get_blato_class( opts.last ) ? 
                opts.shift : 
                nil
    
    raise "#{self} is not ready for production." if production?
    
    task = if cmd.is_a?(Symbol) && instance
      "#{instance.class.to_s.underscore}:#{cmd}"
    else
      pieces = cmd.split(':').map { |s| s.strip }
      task = pieces.join(':')
    end  
    
    raise "Invalid command: #{cmd.inspect}"  if !blato_tasks.include?(task) 
    
    if invoked_tasks.include?( task ) 
      raise "Task already invoked onced: #{ task } (cmd = #{cmd.inspect}, opts = #{opts.inspect}, instance = #{instance.inspect})" 
    end 
       
    invoked_tasks << task
    
    namespace, meth = task.split(':')
    oClass = (instance && instance.class) || eval("#{namespace.camelize}") 
    instance ||= oClass.new
    if instance.method("__#{meth}").arity == 0
      instance.send("__#{meth}")    
    else
      instance.send("__#{meth}", opts)  
    end
    
  end  
  
  module ClassMethods
    def desc( *args )
      case args.size
        when 2
          meth, txt = args
          properties  = {:class=>self, :class_underscore=>self.to_s.underscore, :method=>meth, :opts=>{}, :text=>txt}
        when 3
          meth, opts, txt = args
          properties  = {:class=>self, :class_underscore=>self.to_s.underscore, :method=>meth, :opts=>opts, :text=>txt}
        else
          raise "Only 2 or 3 arguments allowed for :desc."
      end
      task = "#{properties[:class_underscore]}:#{properties[:method]}"
      raise "Task already defined: #{task}" if Blato.blato_tasks.include?(task)
      Blato.blato_tasks << task
      Blato.blato_task_properties[task] = properties
    end
  end
  
  
  def self.mute?
    !!@mute_on
  end  
  
  def self.mute_on
    @mute_on = true
  end
  
  def self.mute_off
    @mute_on = false
  end
  
  def self.extract_command(obj, cmd)
    case cmd
    
      when String
          pieces = cmd.split(':')
         
          if pieces.first == self.to_s.underscore && pieces.size == 2
            Blato.invoke( self, pieces.last.to_sym, *args )
          else
            Blato.invoke( cmd, *args )
          end  
                     
      when Symbol
          Blato.invoke( self, cmd, *args )
    end
  end
  
  def invoke(cmd, opts = {})
    case cmd
    
      when String
          Blato.invoke( cmd, opts = {} )
                    
      when Symbol
          Blato.invoke( cmd, opts, self )
    end
  end # === invoke
  
  def capture_task(cmd, opts = {})
      Blato.mute_on
      
      orig = $stdout
      temp = StringIO.new()

      $stdout = temp

      output = block_given? ?
                  yield :
                  Blato.invoke(cmd, opts , (cmd.is_a?(Symbol) ? self : nil) )
                  

      $stdout = orig

      temp.rewind()
      
      Blato.mute_off
      #output
      temp.read() # print out what was sent to STDOUT  
  end
  
  def capture(command )
    raise "Command required." if command.to_s.strip.empty?
    `#{command} 2>&1`
  end # === capture

  
  def whisper(*args)
    puts *args
  end
  
  def shout( msg , *raw_colors )
    return( whisper(msg) ) if Blato.mute?
    
    
    # Validate colors.
    valid_colors = [:red, :white, :on_black, :yellow]
    colors = raw_colors.flatten.uniq.compact
    invalid_colors  = colors - valid_colors 
    colors = [:red] if colors.empty? || !(invalid_colors).empty?

    HighLine.new.say( %!
       <%= color( %~#{msg}~, #{colors.flatten.map {|c| c.inspect}.join(',') }) %>  
    !.strip + "\n\n" )
  end
  

  
end

# ====================================================================================
# ====================================================================================

# ====================================================================================
# ====================================================================================

# ====================================================================================
# ====================================================================================

# ====================================================================================
# ====================================================================================

# ====================================================================================
# ====================================================================================
class Sass
  include Blato
  
  desc :compile, "Turn all SASS files to CSS."
  def __compile
    return nil if  !Pow('views/skins/jinx/sass').exists?
    compile_results = capture("compass -r ninesixty -f 960 --sass-dir views/skins/jinx/sass --css-dir public/skins/jinx/css -s compressed")
    clean_results   = compile_results.split("\n").reject { |line| 
                                                            line =~ /^unchanged\ / ||
                                                            line.strip =~ /^(compile|exists|create)/
                                                         }.join("\n")
    
    raise( clean_results ) if compile_results['WARNING:'] || compile_results['Error']
    
    whisper "Compiled SASS to CSS"
    
  end # === def
  
  desc :delete, "Delete compiled CSS files.."
  def __delete
    return nil if !Pow('views/skins/jinx/sass').exists?
    Pow('views/skins/jinx/sass').each { |f| 
      if f.file? && f.to_s =~ /\.sass$/ 
        css_file = Pow( 'public/skins/jinx/css', File.basename(f.to_s).sub( /\.sass$/, '') + '.css' )
        css_file.delete if css_file.exists? 
      end
    }
    whisper "Deleted compiled CSS files."
  end
  
end # === class

# ====================================================================================
# ====================================================================================

class Git
  include Blato
  def commit_pending?(raw_out)
    output = (raw_out || __update )
    output['nothing to commit'] ?
      false :
      output  
  end
  
  desc :test, "Executes"
  def __test
    output = capture_task(  :update )
    capture_task(  :update )
    shout "Output: #{output}"
  end
  
  desc :update, "Executes: git add . && git add -u && git status"
  def __update
    invoke 'sass:compile'
    shout capture( 'git add . && git add -u && git status' ), :white
    invoke 'sass:delete'    
  end

  desc :commit, {:msg=>[String, nil]}, 'Gathers comment and commits it. Example: rake git:commit message="My commit." '
  def __commit( msg = nil)
    msg = opts[:msg]
    output = __update
    whisper output
    if commit_pending?(output)
      new_comment = (msg || ask('===> Enter one line comment:')).gsub("'", "\\\\'")
      whisper( capture( %~ git commit -m '#{new_comment}' ~ ) )
      shout "COMMITTED: #{new_comment}",  :white
    else
      shout "NO GO: Nothing to commit."
    end
  end
  
  desc :dev_check, "Used to update and commit development checkpoint. Includes the commit comment for you."
  def __dev_check
    invoke :commit,  :msg=>'Development checkpoint.'
  end # === task    
  
  desc :push, 
       {:open_browser=>true, :migrate=>false}, 
       "Push code to Heroku. Options: open_browser = true, migrate = false"
  def __push( opts )

    output = __update
    
    if commit_pending?(output) 
      whisper output 
      shout "NO GO: You *can't* push, unless you commit."    
    else
      shout 'Please wait as code is being pushed to Heroku...', :blue
      shout capture( 'git push heroku master')
      
      if opts[:migrate]
        shout 'Migrating on Heroku...'
        migrate_results = `heroku rake produciton:db:migrate_up`
        raise "Problem on executing migrate:up on Heroku." if migrate_results[/aborted/i]
        shout migrate_results
        
        shout 'Restarting app servers.'
        shout `heroku restart`
        `heroku open`
      end
      
      `heroku open` if opts[:open_browser]
    end
    
  end # === task
  
  desc :push_and_migrate, "Equivalent to: git:push open_browser=true, migrate=true"
  def __push_and_migrate 
    invoke(:push, :migrate=>true )
  end 
  
end # === Git


Blato.check_for_errors()

if File.basename(__FILE__)[ /blato/i ]
  if ARGV.empty?
    Blato.blato_tasks.each { |task|
      props = Blato.blato_task_properties[task]
      HighLine.new.say( "<%=color('\n#{props[:class_underscore]}:#{props[:method]}', :yellow )%>" +
           %~ <%=color('#{props[:opts].inspect}', :green) %>\n~ )
      HighLine.new.say %~<%=color('#{props[:text].strip}', :white) %>~
    }
    puts "\n\n"
  else
    Blato.invoke(ARGV.first)
  end  
end  
