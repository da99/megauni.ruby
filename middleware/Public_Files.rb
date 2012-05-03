
require "./middleware/Mu_Archive"
require "./middleware/Surfer_Hearts_Archive"

# 
# Serve assets: .js, .css, etc.
#
class Public_Files

    def initialize(app, folders=[])
      @app = app
      @exts = %w{
        .css
        .swf
        .html
        .mp3
        .wav
        .js
        .gif
        .jpg
        .png
        .ico
        /robots.txt
      }
      @raw_folders = folders
    end

    def call e
      dup._call e
    end

    def _call(e)
      @folders = @raw_folders.map { |f| Rack::File.new(f) }
      
      orig = @app.call(e)
      return orig unless orig.first == 404
      
      path    = e["PATH_INFO"]
      allowed = @exts.detect { |f| @exts.include?(File.extname(path)) || @exts.include?(path) }
      
      return orig if !allowed
      
      resp = get_file_response(e)
      return resp if resp 

      orig
    end

    def get_file_response e
      file = e['PATH_INFO']
      files = [file, File.join(file, 'index.html') ]
      resp = nil
      

      files.detect { |f|
        
        @folders.detect { |folder|
          r = folder.call(e)
          resp = r unless r.first == 404
          resp
        }

        resp
      }

      resp
    end

end # ===
