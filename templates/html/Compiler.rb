require 'models/Safe_Writer'
require 'models/Argumentor'
require 'markaby'
require 'models/Gather'
require 'modules/Optional_Constants'
require 'templates/html'
 
class Markaby::Builder
  
  set(:indent, 1)

end # === Markaby::Builder

MARKABY_EXTENSIONS = %w{ 
  Base 
  Base_Js
  Base_Forms
  Base_Message
  Base_Member_Life 
  Base_Rings
  Base_Template_Embed
}

MARKABY_EXTENSIONS.each { |mod|
  require( "templates/en-us/rb_html/extensions/#{mod}" ) 
}

class Ruby_To_Html
  
  FILER = Safe_Writer.new do
    sync_modified_time
    read_folder  %w{ rb_html mustache }
    write_folder %w{ stranger owner member insider }
  end
  
  module Controls
  end

  module Actions
  end
  
  class << self
    
    include Optional_Constants

    def levels
      @levels ||= Ruby_To_Html::Base_Rings::LEVELS.inject({}) {  |memo, level| 
        memo[level] = { 
          :cap => level.capitalize.to_sym, 
          :upcase => level.upcase.to_sym
        }
        memo[level][ :module ] = Ruby_To_Html::Base_Rings.const_get( memo[level][:cap] )
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
        exts << action_extension.const_get(levels[level][:upcase])
      end
      
      exts
    end

    def compile *args

      ops = Argumentor.argue(args) {
        allow :only_level => nil, :glob => '*'
        single :glob
        multi  :only_level, :glob
      }
      
      only_level = ops.only_level
      glob       = ops.glob


      content        = nil
      files          = Dir.glob( path( :rb_html, glob ) )
      allowed_levels = only_level ? [only_level] : Ruby_To_Html::Base_Rings::LEVELS
      compiler       = self

      files.each { |mab_file|
        
        basename   = File.basename(mab_file)
        is_partial = basename[/^__/]
        is_layout  = basename[/\Alayout/]
        next if is_partial || is_layout

        file_name       = basename.sub('.rb', '').to_sym
        layout          = path( :layout, file_name )
        layout_contents = File.read(layout)
        mab             = path(:rb_html, file_name )
        
        allowed_levels.each { |level|

          puts "Compiling: #{mab_file} for #{level}" if Object.const_defined?( :Uni_App )
          
          mustache = path(:mustache, level, file_name)
          html     = path(:html, level, file_name)
          
          # Turn Markaby file into Mustache content.
          tache = Markaby::Builder.new(:file_path => mab_file, :template_name=>file_name) { 

            extend Ruby_To_Html::Base
            extend Ruby_To_Html::Base_Template_Embed
            MARKABY_EXTENSIONS.each { |mod|
              extend eval("Ruby_To_Html::#{mod}")
            }

            compiler.extensions_for_file_name( level, file_name ).each { |mod|
              extend mod
            }

            eval( layout_contents, nil, layout, 1 )

          } # === Markaby::Builder.new
          
          # Compile Mustache file.
          content = Mustache::Generator.new.compile(
            Mustache::Parser.new.compile(
              tache.to_s
          ))
                      
          unless Object.const_defined?( :Uni_App )
            # Save Mustache content.
            puts "Writing: #{mustache}"
            FILER.
              from(mab).
              write(mustache, tache)


            # Save compiled Mustache file.
            puts "Writing: #{html}"
            FILER.
              from(mustache).
              write(html, content)
          end

        } # === Ruby_To_Html::LEVELS.each

      }
      
      return content if files.size == 1
      true
    end

  end # === class << self
  
end # === class Ruby_To_HTML

