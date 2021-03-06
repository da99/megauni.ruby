class Gems < Thor
    
    include Thor::Sandbox::CoreFuncs 
    
    desc :update,  "Installs and updates all gems from manifest (.gems)" 
    def update
      gem_manifest = Pow('~/', PRIMARY_APP, '.gems')
      raise "Gems manifest does not exists: .gems" if !gem_manifest.exists?
      
      gems_to_install = File.read(gem_manifest).strip.split("\n")
      
      if development?
        dev_gems = Pow('~/', PRIMARY_APP, '.development_gems' )
        gems_to_install = gems_to_install + File.read(dev_gems).strip.split("\n")
      end
      
      installed =  capture_all('gem list')
      if gems_to_install.empty?
        whisper  "No gems to install."
      else
        gems_to_install.each { |g|
          gem_name = g.split.first.strip
          if gem_name[/^[a-z0-9]/i] # Starts w/ alpha-numeric character ???
            if installed["#{gem_name} ("]
              whisper "Already installed: #{gem_name}"
            else
              whisper capture_all( "gem install #{gem_name}")
            end
          end
        }
      end    
      
      please_wait 'Gems are being updated. This could take a while...'

      output = capture_all('gem update') 
      whisper output
      output

    end   
     
end # === namespace :gems
