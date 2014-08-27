# === The most basic stuff first... ===

require 'sinatra'
disable :logging

require 'da99_rack_middleware'
use Da99_Rack_Middleware

# -------------- NEWER CODE -----------------------------
%w{

   Surfer_Hearts_Archive

   Redirect_Mobile

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

post "/club-search/" do
  redirect to("/search/"), Perma
end

post "/search/" do 
  name = params['name'] || params['keyword']
  retro = "/#{name}/"
  redirect(to("/#{name}/"), Perma) if Mu_Archive(retro)

  case name
  when %r!menop..se!, %r!ost[eo]+p[oris]+!
    redirect to("/meno-osteo/"), Perma
  else
    Mu_Archive_Read "/search/index.html", :name=>name
  end
end # === post search

[403,404,500].each { |num|
  error num do
    File.read("Public/#{num}.html")
  end
}



