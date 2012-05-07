
require 'builder'
require 'templates/html'

class Ruby_To_Xml
  
  FILER = Safe_Writer.new do
    sync_modified_time
    read_folder  %w{ rb_xml }
    write_folder %w{ xml }
  end
  
  class << self
    
    def compile file_name = '*'
      
      content      = nil
      glob_pattern = path( :rb_xml, '*', file_name )
      files        = Dir.glob(glob_pattern)
      
      files.each { |xml_file|

        file_name = self.file_name(xml_file)
        mustache  = path( :xml, file_name )
        content   = File.read(xml_file)
        str       = ''
        
        compiled      = Builder::XmlMarkup.new( :target => str )
        compiled.instance_eval content, xml_file, 1
        compiled.target!
        
        tache = Mustache::Generator.new.compile(
          Mustache::Parser.new.compile(
            str.to_s
          )
        )

        unless Object.const_defined?( :Uni_App )
          print "Writing: #{mustache}\n"
          FILER.
            write( mustache, tache )
        end
        
        content = tache
      }
      
      return content if files.size == 1
      true
      
    end
    
  end # === class << self

end # === Ruby_To_Xml
