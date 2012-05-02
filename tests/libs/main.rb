require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.print e.message, "\n"
  $stderr.print "Run `bundle install` to install missing gems\n"
  exit e.status_code
end

require 'bacon'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

Bacon.summary_on_exit

ENV['RACK_ENV'] = 'test'
require 'rack/test'
require 'Bacon_Colored'
require 'pry'
require './middleware/Fake_Server'

Dir.glob("./tests/libs/*.rb").each { |f|
  require f unless File.basename(f) == File.basename($0)
}

class Bacon::Context
  
  include Rack::Test::Methods

  def app
    @app ||= begin
               rack    = Rack::Builder.new
               rack.use Fake_Server
               file    = File.expand_path('config.ru')
               content = File.read(file)
               rack.instance_eval(content, file, 1)
               rack.to_app
             end
  end  
  
end # === class

# ======== Include the tests.

if ARGV.size > 1 && ARGV[1, ARGV.size - 1].detect { |a| File.exists?(a) }
  # Do nothing. Bacon grabs the file.
else
  Dir.glob('./tests/*.rb').each { |file|
    require(file.sub '.rb', '' ) if File.basename(file)[%r!\A(C|M|V)_!]
  }
end
