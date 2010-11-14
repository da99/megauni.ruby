require 'models/Delegator_Dsl'
require 'models/Sentry_Sender'

module Ruby_To_Html::Base_Rings
  
  LEVELS = %w{
    stranger
    owner
    insider
    member
  }

  def everybody &blok
    yield
  end
  
  def member_or_insider &blok
    member &blok
    insider &blok
  end
  
  def insider_or_owner &blok
    insider &blok
    owner &blok
  end

  def logged_in &blok
    member &blok
    insider &blok
    owner &blok
  end
   
  LEVELS.each { |level|
    
    eval %~
    
      def #{level} &blok
        # do nothing
      end
    
      module #{level.capitalize}
      
        def #{level} &blok
          # ring :#{level}
          
          mod = "MAB_\#{template_name}_#{level.to_s.upcase}"
          clone = self.clone
          begin
            clone.extend Object.const_get(mod)
          rescue NameError
          end
          show_if "#{level}?" do
            clone.instance_eval( &blok )
          end
          # ring nil
        end
          
      end # === module
      
    ~
    
  }

end # === module




__END__




  def send_to_current_ring *args, &blok
    send_within_ring ring, *args, &blok
  end

  def send_within_ring level, meth_name, *args, &blok
    target = "#{level}_#{meth_name}"
    omni   = "omni_#{meth_name}"
    
    target_def = respond_to?(target)
    omni_def   = respond_to?(omni)

    final = if target_def && omni_def
              raise Method_Overload, "Can't define both: #{target}, #{omni}"
            elsif omni_def
              omni
            else
              target
            end
    
    send(final, *args, &blok)
  end
