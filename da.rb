
require 'cuba'
require 'rack/protection'
require 'securerandom'

Cuba.use Rack::Session::Cookie, :secret => SecureRandom.urlsafe_base64(nil, true)
Cuba.use Rack::Protection

Cuba.define do

  on(get) {

    on 'googlehostedservice.html' do
      res.write 'googled80ce82f00e7fc31'
    end

    on root do
      res.write <<-EOF.strip
        <html>
          <body>
            <p>Go to:</p>
            <a href="http://www.megauni.com/salud/">megauni.com/salud</a><body>
          </body>
        </html>
      EOF
    end
  }

end # === Cuba.define
