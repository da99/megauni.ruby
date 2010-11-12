
class Ruby_To_Xml
  
  RB_XML = 'templates/%s/rb_xml/%s.rb'
  XML    = 'templates/%s/xml/%s/%s.xml'

	class << self
		
    def file_name unknown
      unknown.to_s.
        strip.
        split('/').last.
        sub(/\.(rb|xml)$/, '')
    end

    def path type, *args
      pattern = eval(type.to_s.upcase)
      case type
      when :rb_xml
        args.unshift( 'en-us' ) if args.size == 1
      when :xml
        args.unshift( 'en-us' ) if args.size == 2
      else
        raise ArgumentError, "Unknown type: #{type.inspect}"
      end
      
      pattern % args.map(&:to_s)
    end

	end # === class << self

end # === class
