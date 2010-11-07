require 'models/Safe_Writer'
require 'markaby'
require 'templates/en-us/html/extensions/BASE_MAB'
require 'models/Gather'

module MAB
  
  MODS = %w{ 
    Base 
    Base_Js
    Base_Forms
    Base_Club
    Base_Message
    Base_Member_Life 
  }

end

MAB::MODS.each { |mod|
  require( "templates/en-us/html/__#{mod}" ) 
}
 
require 'templates/extensions/rings'

class Markaby::Builder
  
  set(:indent, 1)
  MAB::MODS.each { |mod| include Object.const_get(mod) }
  include MAB::RINGS

end # === Markaby::Builder

class Ruby_To_HTML
  
  FILER = Safe_Writer.new do

    sync_modified_time
    
    read_folder   %w{xml mab}
    write_folder %w{ mustache stranger owner member insider }
    
  end

  def self.save_file level, mab_file, raw_html_file, content
    html_file = raw_html_file.sub('mustache', "mustache/#{level}")
    parser    = Mustache::Parser.new
    generator = Mustache::Generator.new
    output    = generator.compile(
      parser.compile(
        content.to_s
    ))
    
    FILER.
      from(mab_file).
      write(html_file, output)

    output
  end

  def self.compile file_name
    compile_all file_name, false
  end

  def self.compile_all filename = '*', save_it = true, only_level = nil
    
    content      = nil
    path_to_file = filename == '*' ?
                    "templates/en-us/html/#{filename}.rb" : 
                    filename

    mab_dir              = File.dirname(path_to_file)
    layout_file          = File.join(mab_dir, 'layout.rb')
    layout_file_contents = File.read(layout_file)
    allowed_levels       = only_level ? [only_level] : MAB::RINGS::LEVELS
    
    Dir.glob(path_to_file).each { |mab_file|
      
      # if mab_file['Clubs_by_filename']
      #   
      #   require 'rubygems'; require 'ruby-debug'; debugger
      # end
        
      file_basename = File.basename(mab_file)
      next if file_basename[/\Alayout/] || file_basename[/\A__/]
      
      is_partial    = file_basename[/^__/]
      html_file     = mab_file.sub('html/', 'mustache/').sub('.rb', '.html')
      template_name = file_basename.sub('.rb', '').to_sym
      ext_types     = %w{base ext}
      
      controller_name = file_basename.split('_').reject { |str| str =~ /\A[a-z]/ }.join('_')
      
      mab = Config_Switches.new {
        strings :base, :ext, :dir
        switch :use_base, off
        switch :use_ext,  off
      }
      
      mab.put {
        base   "BASE_MAB_#{controller_name}"
        ext    "MAB_#{file_basename}".sub('.rb', '')
        dir    File.join(mab_dir, 'extensions')
      }
      
      # Figure out if template uses a base or extension.
      ext_types.each { |mod|
          file = "#{mab.get.dir}/#{mab.get.send(mod)}.rb"
          if File.exists?(file)
            require file
            mab.put.send("use_#{mod}")
          end 
      }

      
      allowed_levels.each { |level|
        
        level_mod = MAB::RINGS.const_get(level.capitalize.to_sym)

        puts "Compiling: #{mab_file}" if Uni_App.development?
        mab_content = Markaby::Builder.new(:template_name=>template_name) { 

          extend level_mod

          if mab.ask.use_base?
            mod_class = Object.const_get( mab.get.base )
            mod_class.send :include, BASE_MAB
            extend mod_class
          end

          if mab.ask.use_ext?
            
            # e.g.: MAB_Clubs_by_filename
            extend Object.const_get( mab.get.ext )
            
            # e.g.: MAB_Clubs_by_filename_STRANGER
            level_mod = :"#{mab.get.ext}_#{level.to_s.upcase}"
            if Object.const_defined?(level_mod)
              extend Object.const_get(level_mod)
            end
            
          end

          eval(
            layout_file_contents.sub("{{content_file}}", file_basename),
            nil, 
            layout_file, 
            1
          )

        } # === Markaby::Builder.new

        content = save_file(level, mab_file, html_file, mab_content)
        
    } # === MAB::LEVELS.each

    }
    content
  end
  
end # === class Ruby_To_HTML

