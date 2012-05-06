
describe "404" do
  
  it "displays link to egg timers" do
    get "/missing-page/"
    last_response.status.should == 404
    last_response.body.should.match %r!"/my-egg-timer/">!
    last_response.body.should.match %r!"/busy-noise/">!
  end
  
  it "displays location" do
    get "/missing-page/"
    last_response.status.should == 404
    last_response.body.should.match %r!document.writeln\(window.location.href\);!
  end

end # === 404

