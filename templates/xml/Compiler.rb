
require 'builder'
require 'templates/html'

class Ruby_To_Xml
  
  FILER = Safe_Writer.new do
    sync_modified_time
    read_folder  %w{ rb_xml }
    write_folder %w{ stranger owner member insider }
  end
  
  class << self
    
    def compile file_name = '*'
      
      content = nil

      glob_pattern = file_name == '*' ?
                          "templates/*/rb_xml/#{file_name}.rb" :
                          file_name
                          
      files = Dir.glob(glob_pattern)
      files.each { |xml_file|

        file_name = self.file_name(xml_file)
        mustache  = path( :xml, :stranger, file_name )
        content   = File.read(xml_file)
        str       = ''
        
        compiled      = Builder::XmlMarkup.new( :target => str )
        compiled.instance_eval content, xml_file, 1
        compiled.target!
        
        unless Object.const_defined?( :Uni_App )
          FILER.
            write( mustache, str )
        end
        
        content = str
      }
      
      return content if files.size == 1
      true
      
    end
    
  end # === class << self

end # === Ruby_To_Xml
