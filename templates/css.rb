
require 'sass'
require 'compass'
require 'ninesixty'

class Ruby_To_CSS
  
  def self.sass_files
    Dir.glob('templates/*/css/*.sass')
  end

  def self.compile_all
    new_files = {}
    sass_files.each do |sass_file|
      
      sass_dir      = File.dirname(sass_file)
      css_file_name = sass_file.
                        gsub('.sass', '.css').
                        sub('templates', 'stylesheets').
                        gsub('sass', '').
                        sub('css/', '')
      
      css_file      = File.join( 'public', css_file_name )
      
      eng = Sass::Engine.new(
        File.read(sass_file), 
        :load_paths => [ sass_dir ] + Compass.sass_engine_options[:load_paths] 
      )
      
      begin
        css_content = eng.render
        puts "Writing: #{css_file}"
        File.open(File.expand_path(css_file), 'w' ) do |f|
          f.write css_content
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

    new_files
    
  end

  def self.compile file_name = nil
    
    vals = {} 
    
    Dir.glob(file_name || 'templates/*/css/*.sass').each do |sass_file|
      
      sass_dir    = File.dirname(sass_file)
      css_file    = File.join( 'public', sass_file.gsub('.sass', '.css').sub('templates', 'stylesheets').sub('sass/', '') )
      css_content = Sass::Engine.new(
        File.read(sass_file), 
        :load_paths => [ sass_dir ] + Compass.sass_engine_options[:load_paths] 
      ).render

      vals[sass_file] = [css_file, css_content]
      
    end

    file_name ?
      vals[file_name].last :
      vals
  end

  def self.delete_css
    Dir.glob('public/styles/*/*.css').each { |file|
      puts file
    }
  end

end # === class








    # output = `compass --dry-run --trace -r ninesixty -f 960 --sass-dir templates/en-us/sass --css-dir public/styles/en-us -s compressed 2>&1`
    # puts output
    # puts $?.exitstatus.to_s
    #   clean_results   = results.split("\n").reject { |line| 
    #     line =~ /^unchanged\ / ||
    #       line.strip =~ /^(compile|exists|create)/
    #   }.join("\n")

    #   raise( clean_results ) if results['WARNING:'] || results['Error']
