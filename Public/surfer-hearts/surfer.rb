
require 'sinatra'
require 'open-uri'

configure do
  S3_PREFIX = "http://surferhearts.s3.amazonaws.com/public"
  REDIS = if ENV["REDISTOGO_URL"]
            require 'redis'
            uri = URI.parse(ENV["REDISTOGO_URL"])
            Redis.new(:host => uri.host, :port => uri.port, :password => uri.password) 
          else
            false
          end
  FILE_500 = File.read("500.html") { |file| file.read }
end

not_found do
  personalize 
end

error do
  personalize
end

def personalize txt = nil
  (txt || FILE_500).gsub("'IP_ADDRESS'", "'#{request.ip}'")
end

# Permanent redirect.
def redirect_301 *pieces 
  url = File.join( S3_PREFIX, *pieces )
  redirect url, 301 
end

def cache_it days
  response.headers['Cache-Control'] = "public, max-age=#{60 * 60 * 12 * days.to_i }"
end

def get_file file_path
  r_key = "file_" + file_path.gsub(/[^a-z0-9A-Z]{1,}/, '_')
  
  if REDIS
    cache = REDIS.get(file_path) 
    return cache if cache
  end
  
  url = File.join( S3_PREFIX, file_path)
  
  contents = open(url) { |file| file.read } 
  
  REDIS.set( r_key, contents) if REDIS
  
  cache_it 15

  contents
end

get '/' do
  get_file 'index.html'
end

get "/500.html" do
  cache_it 1
  personalize
end

get "/googlehostedservice.html" do
  "googlecdbfb88300e7fc31"
end

%w{ index about blog search }.each { |file|
  get "/#{file}.html" do
    redirect "/#{file}/", 301
  end
  
  get "/#{file}/" do
    get_file "#{file}.html"
  end
}

get "/robots.txt" do
  get_file "robots.txt"
end

get "/favicon.ico" do
  redirect_301 "favicon.ico"
end

%w{ media javascripts }.each { |prefix|
  get "/#{prefix}/*"  do
    redirect_301 prefix, params[:splat] 
  end
}

%w{ search blog heart_link heart_links }.each { |url|
  get "/#{url}" do
    redirect "/#{url}/", 301
  end

  get "/#{url}/:id/" do
    get_file File.join( "/#{url}/", params[:id].to_i.to_s + '.html' )
  end

  get( "/#{url}/*" ) do
    
    splat = params[:splat].to_s.strip.gsub('+', '-').gsub( ' ', '-').gsub('%20', '-')
    if splat.empty?
      splat = "index.html"
    end
    if splat =~ /\/\Z/
      splat = splat.sub(/\/\Z/, '.html')
    end
    
    get_file File.join( "/#{url}/", splat )
  end
}

get "/images/blank.gif" do
  redirect "http://www.googlesomewrongpage.com", 301
end

get "/archives/" do
  redirect "/", 307
end

get "/rss/" do
  redirect "/rss.xml", 301
end

%w{ sitemap rss }.each { |filename| 
  get "/#{filename}.xml" do
    cache_it 15
    content_type 'application/xml', :charset => 'utf-8'
    File.open("#{filename}.xml") { |file| file.read }
  end
}

get "/media/heart_links/images/*" do
  redirect File.join("http://surferhearts.s3.amazonaws.com/heart_links/", params[:splat]), 301
end

