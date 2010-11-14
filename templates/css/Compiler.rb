
class Ruby_To_Css

  class << self
    
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
          
          unless Object.const_defined?( :Uni_App )
            puts "Writing: #{css_file}"

            FILER.
            from(sass_file).
            write( css_file, css )
          end

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
