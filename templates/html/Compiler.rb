require 'models/Safe_Writer'
require 'markaby'
require 'models/Gather'
require 'modules/Optional_Constants'
require 'templates/html'
 
class Markaby::Builder
  
  set(:indent, 1)

end # === Markaby::Builder

%w{ 
  Base 
  Js
  Forms
  Club
  Message
  Member_Life 
  Rings
  Template_Embed
}.each { |mod|
  require( "templates/extensions/#{mod}" ) 
}

class Ruby_To_Html
  
  FILER = Safe_Writer.new do

    sync_modified_time
    
    read_folder  %w{ rb_xml rb_html mustache }
    write_folder %w{ stranger owner member insider }
    
  end

  class << self
    
    include Optional_Constants

    def save_file level, file_name, tache

      # Save Mustache file.
      mab      = path(:rb_html, file_name )
      mustache = path(:mustache, level, file_name)
      html     = path(:html, level, file_name)
      
      FILER.
        from(mab).
        write(mustache, tache)

      # Save compiled Mustache file.
      output = Mustache::Generator.new.compile(
        Mustache::Parser.new.compile(
          tache.to_s
      ))

      FILER.
        from(mustache).
        write(html, output)

      output
    end

    def levels
      @levels ||= Ruby_To_Html::Rings::LEVELS.inject({}) {  |memo, level| 
        memo[level] = { 
          :cap => level.capitalize.to_sym, 
          :upcase => level.upcase.to_sym
        }
        memo[level][ :module ] = Ruby_To_Html::Rings.const_get( memo[level][:cap] )
        memo
      } 
    end

    def extensions_for_file_name level, file_name
      exts = []
      exts << levels[level][:module]

      exts_dir = File.join( 'templates/en-us/rb_html/extensions' )
      
      control                = file_name.to_s.split('_').reject { |str| 
                                  str =~ /\A[a-z]/ 
                               }.join('_')
      
      control_extension_file = File.join( exts_dir, control )
      control_extension      = require_if_exists( control_extension_file ) && Ruby_To_Html::Controls.const_get( control )
      exts << control_extension if control_extension
      
      action                = file_name.to_s.sub(control, '')
      action_extension_file = File.join( exts_dir, file_name.to_s)
      action_extension      = require_if_exists( action_extension_file ) && Ruby_To_Html::Actions.const_get( file_name )
      if action_extension
        exts << action_extension 
        if action_extension.const_defined?( levels[level][:cap] )
          exts << action_extension.const_get(levels[level][:cap])
        end
      end
      exts
    end

    def compile only_level = nil, glob = '*'

      content = nil
      files   = Dir.glob( path( :rb_html, glob ) )
      
      mab_dir              = File.dirname( files.first )
      layout_file          = File.join(mab_dir, 'layout.rb')
      layout_file_contents = File.read(layout_file)
      allowed_levels       = only_level ? [only_level] : Ruby_To_Html::Rings::LEVELS
      compiler             = self

      files.each { |mab_file|

        basename   = File.basename(mab_file)
        file_name  = basename.sub('.rb', '').to_sym
        
        is_partial = basename[/^__/]
        is_layout  = basename[/\Alayout/]
        next if is_partial || is_layout
        
        allowed_levels.each { |level|

          puts "Compiling: #{mab_file} for #{level}" if Uni_App.development?
          
          mab_content = Markaby::Builder.new(:template_name=>file_name) { 

            extend Ruby_To_Html::Base
            extend Ruby_To_Html::Template_Embed
            
            compiler.extensions_for_file_name( level, file_name ).each { |mod|
              extend mod
            }

            eval(
              layout_file_contents.sub("{{content_file}}", basename),
              nil, 
              layout_file, 
              1
            )

          } # === Markaby::Builder.new

          content = save_file(level, file_name, mab_content)

        } # === Ruby_To_Html::LEVELS.each

      }
      
      return content if files.size == 1
      true
    end

  end # === class << self
  
end # === class Ruby_To_HTML

