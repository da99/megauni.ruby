
raise '$KCODE not set to UTF8 in start file.' unless $KCODE == 'UTF8'

class Bacon::Context
  include Rack::Test::Methods
end

describe 'The HelloWorld App' do
  def app
    Sinatra::Application
  end

  it "says hello" do
    get '/'
    last_response.should.be.ok
    last_response.body.should =~ /mega uni/i
  end
end




