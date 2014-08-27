
describe "Custom 404" do

  it "displays link to egg timers" do
    get "/missing-page"
    http_code.should == 404
    html.should.match %r!"/my-egg-timer/">!
    html.should.match %r!"/busy-noise/">!
  end

  it "displays location" do
    get "/missing-page/"
    last_response.status.should == 404
    last_response.body.should.match %r!document.writeln\(window.location.href\);!
  end

  it "saves a copy of the exception to the log" do
    target = "/missing-page-#{rand 100}/"
    get target
    e = Dex.reverse_order(:created_at).limit(1).first
    e[:REQUEST_PATH].should == target
  end

  it "sets exception log message to: 404 /path" do
    target = "/missing-page-#{rand 100}/"
    get target
    e = Dex.reverse_order(:created_at).limit(1).first
    e[:message].should == "404 #{target}"
  end

end # === 404

describe "Custom 500" do

  it "displays location" do
    raise_errors_false { get "/raise-error-test/" }
    last_response.status.should == 500
    last_response.body.should.match %r!document.writeln\(window.location.href\);!
  end

end # === Custom 500

describe "Custom non-404, non-500" do

  it "does not record 401 errors to exception log" do
    raise_errors_false {
      e = last_exception
      get "/set-status/401/"
      last_exception.should == e
    }
  end

  it "sets exception to HTTP_Status_Error" do
    raise_errors_false {
      get "/set-status/506/"
      last_exception[:exception].should == "The_App::HTTP_Status_Error"
      last_exception[:message].should == "506 /set-status/506/"
    }
  end

  it "does not alter body" do
    raise_errors_false {

      get("/set-status/505/")
      .body.should == "Error for test: 505"

    }
  end

end # === Custom errors
