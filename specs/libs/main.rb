


require 'Bacon_Colored'
require 'pry'

PERM     = 301
TEMP     = 302
BING_URL = 'http://www.mises.org/'

def it_redirects code, path, new_path
  it "redirects w/ #{code} #{path} -> #{new_path}" do
    get path
    redirects_to new_path, code
  end
end


class Bacon::Context

  attr_reader :html, :http_code, :redirect_url

  def get path
    url = "http://localhost:#{ENV['PORT']}#{path}"
    raw = `bin/get -w '%{http_code} %{redirect_url}' "#{url}"`

    lines         = raw.split("\n")
    info          = raw.split("\n").pop.sub(/(\d\d\d) /, '')

    @html         = lines.join "\n"
    @http_code    = $1.to_i
    @redirect_url = info.empty? ? '' : info
  end # === def get

  def redirects_to path, code = nil
    http_code.should == code if code

    if path[/^\//]
      @redirect_url.sub(/https?:\/\/localhost:\d+/, '').should == path
    else
      @redirect_url.should == path
    end
  end

end # === class


