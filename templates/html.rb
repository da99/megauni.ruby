
class Ruby_To_Html
  
  RB_HTML  = 'templates/%s/rb_html/%s.rb'
  MUSTACHE = 'templates/%s/mustache/%s/%s.html'
  HTML     = 'templates/%s/html/%s/%s.html'
  
  class << self
    
    def path type, *args
      pattern = eval(type.to_s.upcase)
      case type
      when :rb_html
        args.unshift( 'en-us' ) if args.size == 1
      when :mustache, :html
        args.unshift( 'en-us' ) if args.size == 2
      else
        raise ArgumentError, "Unknown type: #{type.inspect}"
      end
      
      pattern % args
    end
    
  end # === class << self
  
end # === class

