
module Optional_Constants
    
    def extend_if_exists target, name
      begin
        mod = eval( name )
        target.extend mod
        true
      rescue NameError => e
        raise e unless e.messages =~ /uninitialized constant #{name}/
          false
      end
    end

    def require_if_exists path
      begin
        require path
      rescue LoadError => e
        raise( e ) unless e.message =~ /no such file to load -- #{path}/
          nil
      end
    end

end # === module
