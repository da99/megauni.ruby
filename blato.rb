#!/home/da01/rubyee/bin/ruby

require 'rubygems'
require 'sequel/extensions/inflector'
require 'pow'
require 'highline'
require 'stringio' 




APP_NAME = File.basename(File.expand_path('.'))
MEGA_APP_NAME = 'megauni'
RAKE_HELPERS = 'helpers/rake'
BLATO_HELPERS = '/home/da01/' + MEGA_APP_NAME + '/helpers/blato'



module Blato
  def self.app_name
    @app_name ||= Pow().to_s.split('/').last
  end
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
    # Check to see if all links are valid.
    if APP_NAME != MEGA_APP_NAME
      
      if development? 
        raise "This file, #{__FILE__}, has to be a symlink." if !File.symlink?(__FILE__)    
      end # === if development?

    end  
    
    blato_tasks.each { |task| 
      underscored, meth = task.split(':').map { |s| s.strip }
      oClass = eval underscored.camelize
      if !oClass.method_defined?("__#{meth}")
        raise "#{oClass}:#{meth} does not exist." 
      end
    }
  end
  
  def self.colorize_text(raw_txt, *raw_colors)
    colors = raw_colors.map {|c| c.inspect }.join(', ')
    '<%%=color( %s , %s )%%>' % [ raw_txt.inspect, colors ]
  end
  
  def self.get_blato_class(raw_name)
   name = raw_name.to_s.strip.camelize
   return nil if !blato_classes.map { |c| c.to_s }.include?(name)
   eval name 
  end
  
  def self.write_file( file_path, raw_txt )

    file  = Pow( raw_file_path.to_s )
    raise ArgumentError, "File path to check is empty." if file.empty?
    raise ArgumentError, "#{file_path} already exists." if file.exists?
      
    txt = raw_txt.to_s.strip

    if ENV['debug']
      puts "::::This would have been written::::"
      puts "::Filename::", file_path
      puts "\n::Content::\n", txt
    else
      file.create { |f|
        f.puts txt
      }
    end
  
    "Finished writing: #{file_path}"  
  end
  
  def self.ln_these(target, new_link)
    output = capture("ln -s  %s %s", target, new_link)
    raise output if !output.to_s.strip.empty?
    output
  end
  
  def self.invoke( *args )  

    instance = get_blato_class( args.first.class ) ? 
                args.shift : 
                nil
                
    cmd = args.shift
    
    raise "#{self} is not ready for production." if production?
    
    task = if cmd.is_a?(Symbol) && instance
      "#{instance.class.to_s.underscore}:#{cmd}"
    else
      pieces = cmd.split(':').map { |s| s.strip }
      task = pieces.join(':')
    end  
    
    raise "Invalid command: #{cmd.inspect}"  if !blato_tasks.include?(task) 
    
    if invoked_tasks.include?( task ) 
      raise "Task already invoked onced: #{ task } (cmd = #{cmd.inspect}, opts = #{args.inspect}, instance = #{instance.inspect})" 
    end 
       
    invoked_tasks << task
    
    namespace, meth = task.split(':')
    oClass = (instance && instance.class) || eval("#{namespace.camelize}") 
    instance ||= oClass.new
    
    instance.send("__#{meth}", *args)  
    
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
    
    def bla(*args, &blok)
      desc *args
      define_method "__#{args.first}", &blok
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
  
  def invoke(cmd, *args)
    case cmd
    
      when String
          Blato.invoke( cmd,  *args )
                    
      when Symbol
          Blato.invoke( self, cmd, *args  )
    end
  end # === invoke
  
  def capture_task(cmd, *args)
      Blato.mute_on
      
      orig = $stdout
      temp = StringIO.new()

      $stdout = temp

      block_given? ?
           yield :
           Blato.invoke( (cmd.is_a?(Symbol) ? self : nil), cmd, *args )
                  

      $stdout = orig

      temp.rewind()
      
      Blato.mute_off
      temp.read() # print out what was sent to STDOUT  
  end
  
  # Example:
  #   capture( 'git commit -m %s', "My commit's message with a \" mark.")
  #   ==> git commit -m "My commit's message with a \\" mark."
  # The method automatically escapes and quotes content using String#inspect.
  def capture( *args )
    case args.size
      when 1
        command = args.first
        raise "Command required." if command.to_s.strip.empty?
        `#{command} 2>&1`  
      when 2
        cmd_line, raw_text = args
        text = [raw_text].flatten.map {|t| t.inspect}
        `#{cmd_line % text} 2>&1`
      else
        raise "Only 1 or two arguments allowed."    
    end

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

    HighLine.new.say( Blato.colorize_text( msg.strip, *colors ) )
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


# ====================================================================================
# ====================================================================================


class Core
  include Blato
  desc :install, "Install blato.rb as an executable, 'blato'."
  def __install
    path = HighLine.new.ask( Blato.colorize_text("Path:", :white) ) 
    cmd = "ln -s #{File.expand_path(__FILE__)} #{Pow(path) / 'blato'}"
    results = capture(cmd)
    results.to_s.empty? ?
      whisper( "Success: #{cmd}" ) :
      shout( results ) ;
  end
end


if Blato.development?
  Pow(BLATO_HELPERS).sort.each {|f|
    if f.file? && f.to_s[ /blato\.rb$/ ]
      require f
    end
  }
end



Blato.check_for_errors()

if File.basename(__FILE__)[ /blato/i ]
  if ARGV.empty?
  else
    puts( " * " * 20)
    case ARGV.first
      when '-h', '--help'
        puts "-T [PATTERN]"
        puts "TASK"
      when '-T'
        current_model = nil
        tasks = case ARGV.size
          when 2 # === E.g.:  -T git
          # puts ARGV.inspect
            Blato.blato_tasks.select {|t| t.to_s[ARGV[1]] }
          else
            Blato.blato_tasks
        end
        
        tasks.each { |task|
          props = Blato.blato_task_properties[task]
          
          if current_model != props[:class]
            current_model = props[:class]
            HighLine.new.say( (' * ' * 10) + props[:class_underscore].to_s.upcase )
          end
          
          task_name = props[:class_underscore].to_s + ':' + props[:method].to_s
          HighLine.new.say( 
            Blato.colorize_text(task_name ,  :white  ) +
            ' ' + Blato.colorize_text( props[:opts].inspect, :black , :on_white) 
          ) 
          HighLine.new.say( 
            Blato.colorize_text( props[:text], :yellow )  + "\n\n"
          )
          
        }
      else
        Blato.invoke(ARGV.first)
        puts "\n\n"
    end # === case
  end  
end  