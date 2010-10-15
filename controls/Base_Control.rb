require 'views/Base_View'
require 'models/Hash_Sym_Or_Str_Keys'

module Base_Control

  # ======== Class Methods  ======== 
  class << self
    def included klass
      klass.extend Class_Methods
    end
  end # === class << self

  module Class_Methods
    
    def top_slash
      @path = '/'
    end
    
    def current_path
      @path
    end
    
    def path sub_path
      @path = sub_path
    end
    
    def method_missing name, *args, &blok
      case name
      when :post, :get, :put, :delete
        sub_path = args.shift
        raise ArgumentError, "Unknown arguments: #{args.inspect}" unless args.empty?
        controller = self
        Uni_App.send(name, File.join(current_path, sub_path, '/') ) do
          control controller.to_s
          instance_eval &blok
        end
      else
        super
      end
    end

    # def get sub_path, &blok
    #   controller = self
    #   Uni_App.get File.join(current_path, sub_path, '/') do
    #     control controller.to_s
    #     instance_eval &blok
    #   end
    # end
    
  end # === module Class_Methods

  
  # ======== INSTANCE stuff ======== 
  
end # === Base_Control



