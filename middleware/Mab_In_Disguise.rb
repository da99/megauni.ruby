require 'models/Safe_Writer'
require 'markaby'
require 'templates/en-us/mab/extensions/BASE_MAB'
require 'models/Gather'


MAB_MODS = %w{ 
  Base 
  Base_Js
  Base_Forms
  Base_Club
  Base_Message
  Base_Member_Life 
}

MAB_MODS.each { |mod|
  require( "templates/en-us/mab/__#{mod}" ) 
}

class Markaby::Builder
  
  set(:indent, 1)
  MAB_MODS.each { |mod| include Object.const_get(mod) }

end # === Markaby::Builder

class Mab_In_Disguise
  
  FILER = Safe_Writer.new do

    sync_modified_time
    
    read_folder   %w{xml mab}
    write_folder %w{ mustache }
    
  end

  def self.save_file mab_file, html_file, content
      parser    = Mustache::Parser.new
      generator = Mustache::Generator.new
      output    = generator.compile( 
                    parser.compile(
                      content.to_s
                  ))
      FILER.
        from(mab_file).
        write(html_file, output)
  end

  def self.compile file_name
    compile_all file_name, false
  end

  def self.compile_all filename = '*', save_it = true
    
    content      = nil
    path_to_file = filename == '*' ?
                    "templates/**/mab/#{filename}.rb" : 
                    filename

    Dir.glob(path_to_file).each { |mab_file|
      
      next if mab_file.split('/').last[/\Alayout/]
      
      mab_dir       = File.dirname(mab_file)
      layout_file   = File.join(mab_dir, 'layout.rb')
      file_basename = File.basename(mab_file)
      is_partial    = file_basename[/^__/]
      html_file     = mab_file.sub('mab/', 'mustache/').sub('.rb', '.html')
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
      
      ext_types.each { |mod|
          file = "#{mab.get.dir}/#{mab.get.send(mod)}.rb"
          if File.exists?(file)
            require file
            mab.put.send("use_#{mod}")
          end 
      }

      puts "Compiling: #{mab_file}" if Uni_App.development?
        content     = \
          if is_partial
            Markaby::Builder.new(:template_name=>template_name) { 
              eval( File.read(mab_file), nil, mab_file , 1)
            }
          else
            Markaby::Builder.new(:template_name=>template_name) { 
              
              if mab.ask.use_base?
                mod_class = Object.const_get( mab.get.base )
                mod_class.send :include, BASE_MAB
                extend mod_class
              end
            
              if mab.ask.use_ext?
                extend Object.const_get( mab.get.ext )
              end
              
              eval(
                File.read(layout_file).sub("{{content_file}}", file_basename),
                nil, 
                layout_file, 
                1
              )
              
            }
          end

        save_file(mab_file, html_file, content) if save_it
      
    }
    
    content
  end
  
end # === class Mab_In_Disguise

