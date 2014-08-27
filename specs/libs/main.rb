


require 'Bacon_Colored'
require 'pry'

PERM     = 301
TEMP     = 302
BING_URL = 'http://www.mises.org/'

class Bacon::Context

  attr_reader :http_code, :redirect_url

  def get path
    url = "http://localhost:#{ENV['PORT']}#{path}"
    raw = `bin/get -w '%{http_code} %{redirect_url}' "#{url}"`
    last_line     = raw.split("\n").last
    @http_code    = last_line.shift.to_i
    @redirect_url = last_line.pop.shift
    @redirect_url = nil if redirect_url.empty?
  end # === def get

  def redirects_to path
    if path[/^\//]
      @redirect_url.sub(/https?:\/\/localhost:\d+/, '').should == path
    else
      @redirect_url.should == path
    end
  end

end # === class




