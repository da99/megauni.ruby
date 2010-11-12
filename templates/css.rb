
require 'sass'
require 'compass'
require 'ninesixty'
require 'models/Safe_Writer'

class Ruby_To_Css
  
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

  end # === class << self

end # === class

