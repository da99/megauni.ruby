
module Spawn_Protection
  
  attr_reader :valid_spawn_ignore

  # Accepts:
  #    new_vals - { '@something' => 'some val' }
  #    
  def spawn new_vals = {}
    origin = self
    copy   =  origin.dup

    dont_copy = SPAWN_IGNORE
    @valid_spawn_ignore ||= \
      dont_copy.select { |ivar| ivar['@'] != 0 }.empty?
    unless valid_spawn_ignore
      raise "Invalid values for spawn ignore: #{dont_copy.inspect}"
    end

    origin.instance_variables.each { |ivar|
      unless dont_copy.include?(ivar)
        
        new_val = new_vals[ivar] || origin.instance_variable_get(ivar)
        new_dup = begin
                    new_val.dup
                  rescue TypeError
                    new_val
                  end
        
        copy.instance_variable_set(
          ivar, 
          new_dup
        )
        
      end
    }

    copy
  end

end

