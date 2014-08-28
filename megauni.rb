# === The most basic stuff first... ===

require 'sinatra'
disable :logging

require './middleware/Timer_Public_Files'
use Timer_Public_Files

require './middleware/My_Egg_Timer_Redirect'
use My_Egg_Timer_Redirect

require 'da99_rack_middleware'
use Da99_Rack_Middleware

# -------------- NEWER CODE -----------------------------
%w{

   Surfer_Hearts_Archive

   Mu_Archive_Redirect

   Mu_Archive

   Public_Files

}.each { |name|

 require "./middleware/#{name}"

 case name
 when 'Public_Files'
   use Public_Files, [
     'Public',
     Surfer_Hearts_Archive::Dir
   ]
 else
   use Object.const_get(name)
 end

}


[403,404,500].each { |num|
  error num do
    File.read("Public/#{num}.html")
  end
}

if ENV['IS_DEV']
  get '/raise-error-for-test' do
    something
  end
end


