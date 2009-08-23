class Gems
    
    include Blato 
    
    bla :update,  "Installs and updates all gems from manifest (.gems)" do
      gem_manifest = Pow('.gems')
      raise "Gems manifest does not exists: .gems" if !gem_manifest.exists?
      
      gems_to_install = gem_manifest.read.strip.split("\n")
      installed =  capture('gem list')
      if gems_to_install.empty?
        shout  "No gems to install.", :white
      else
        gems_to_install.each { |g|
          gem_name = g.split.first
          if installed["#{gem_name} ("]
            shout "Already installed: #{gem_name}", :white
          else
            shout  capture( "gem install #{g}"), :white
          end
        }
      end    
      whisper 'Please wait as gems are updated...'
      shout  capture('gem update'), :white
    end   
     
end # === namespace :gems