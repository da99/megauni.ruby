
class Bacon::Context
  
  # === Custom Helpers ===

  def utc_string
    Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')
  end

  def ssl_hash
    {'HTTP_X_FORWARDED_PROTO' => 'https', 'rack.url_scheme'  => 'https' }
  end

  def last_response_should_be_xml
    last_response.headers['Content-Type'].should == 'application/xml;charset=utf-8'
  end

  def follow_ssl_redirect!
    follow_redirect!
    follow_redirect!
  end

  def assert_equal a, b
    a.should == b
  end

  def assert_raises_with_message( err_class, err_msg, &blok )
    err = assert_raises(err_class, &blok)
    case err_msg
    when String
      err_msg.should ==  err.message
    when Regexp
      err_msg.should.match err.message
    else
      raise ArgumentError, "Unknown class for error message: #{err_msg.inspect}"
    end
  end

  # 301 - Permanent
  # 302 - Temporay
  def assert_redirect(loc, status = 301)
    loc.should == last_response.headers['Location'].sub('http://example.org', '')
    status.should == last_response.status
  end

  def assert_last_response_ok
    200.should == last_response.status
  end

end # === Bacon::Context

