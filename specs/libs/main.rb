


require 'ostruct'
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

  attr_reader :html, :http_code, :redirect_url, :last_request

  def header key, val
    @header ||= {}
    @header[key] = val
  end

  def get path
    @last_response = nil
    @last_request = begin
                      o = OpenStruct.new
                      o.path_info = path.sub(/https?:\/\/.+:\d+/i, '')
                      o.full_path = path
                      o
                    end

    headers = (@header || {}).
      map { |pair| "--header \"#{pair.first}: #{pair.last}\""}.
    join(' ')

    url = if path[/https?:\/\//i]
            path
          else
            "http://localhost:#{ENV['PORT']}#{path}"
          end

    raw = `bin/get #{headers} -w '%{http_code} %{redirect_url}' "#{url}"`

    lines         = raw.split("\n")
    info          = lines.pop.sub(/(\d\d\d) /, '')

    @html         = lines.join "\n"
    @http_code    = $1.to_i
    @redirect_url = info.empty? ? '' : info
    last_response
  end # === def get

  def follow_redirect!
    fail "Can't redirect on #{http_code.inspect}" unless [301, 302].include?(http_code)
    get(redirect_url)
  end

  def redirects_to *args
    case
    when args.size == 1
      path, code = args
    when args.size == 2 && args.first.is_a?(String)
      path, code = args
    when args.size == 2 && args.first.is_a?(Numeric)
      code, path = args
    else
      fail "Unknown args: #{args.inspect}"
    end

    http_code.should == code if code

    if path[/^\//]
      redirect_url.sub(/https?:\/\/localhost:\d+/, '').should == path
    else
      redirect_url.should == path
    end
  end

  def last_response
    @last_response ||= begin
                         o = OpenStruct.new
                         o.status = http_code
                         o.body   = html
                         o.full_path = redirect_url
                         def o.ok?
                           status == 200
                         end
                         o
                       end
  end

end # === class


