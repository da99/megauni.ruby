
class Ruby_To_Html
  
  RB_HTML  = 'templates/%s/rb_html/%s.rb'
  MUSTACHE = 'templates/%s/mustache/%s/%s.html'
  HTML     = 'templates/%s/html/%s/%s.html'
  
  class << self
    
    def path type, *args
      
      case type
      when :rb_html
        args.unshift( 'en-us' ) if args.size == 1
      when :mustache, :html
        args.unshift( 'en-us' ) if args.size == 2
      when :layout
        file_path = path( :rb_html, *args )
        dir       = File.dirname(file_path)
        return File.join(dir, 'layout.rb')
      else
        raise ArgumentError, "Unknown type: #{type.inspect}"
      end
      
      pattern = eval(type.to_s.upcase)
      pattern % args
      
    end # === def path
    
  end # === class << self
  
end # === class

