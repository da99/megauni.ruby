
require 'sass'
require 'compass'
require 'ninesixty'
require 'models/Safe_Writer'

class Ruby_To_CSS
  
  SASS = 'templates/%s/sass/%s.sass'
  CSS  = 'public/stylesheets/%s/%s.css'
  
  FILER = Safe_Writer.new do
    read_folder %w{ sass }
    write_folder %w{ css }
  end

  class << self

    def file_name unknown
      case unknown
      when Symbol
        return unknown
      else
        unknown.to_s.
          split('/').last.
          sub('.sass', '').
          sub('.css', '').
          to_sym
      end
    end

    def path type, *args
      pattern = eval("#{type.to_s.upcase}")
      
      case args.size
      when 1
        args.unshift 'en-us'
      end
      
      # Ensure last argument is a file_name 
      # and not a file path.
      file_path = args.pop
      args.push file_name(file_path).to_s
      
      pattern % args
    end

    def compile file_name = '*'
      sass_files = Dir.glob( path( :sass, file_name ) )
      output = nil

      sass_files.each do |sass_file|

        sass_dir   = File.dirname(sass_file)
        css_file   = path( :css, sass_file )
        load_paths = [ sass_dir ] + Compass.sass_engine_options[:load_paths] 

        eng = Sass::Engine.new(
          File.read(sass_file), 
          :load_paths => load_paths
        )

        begin
          output = css = eng.render
          puts "Writing: #{css_file}"

          FILER.
          from(sass_file).
          write( css_file, css )

        rescue Sass::SyntaxError
          if File.read(sass_file)['IGNORE UNDEFINED'] && $!.message =~ /Undefined variable/
            puts "IGNORING: #{sass_file}: #{$!.class} - #{$!.message}"
            next
          else
            raise $!
          end
        end

      end

      return output if sass_files.size == 1
      true

    end # === def compile
    
  end # === class << self

end # === class

