
class Ruby_To_Xml
  
  RB_XML = 'templates/%s/rb_xml/%s.rb'
  XML    = 'templates/%s/xml/%s/%s.xml'

	class << self
		
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
      
      pattern % args
    end

	end # === class << self

end # === class
