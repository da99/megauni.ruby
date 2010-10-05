
ENV['RACK_ENV'] = 'test'


require 'rubygems'
require 'test/unit'
require 'test/unit/testresult'
require 'test/unit/testcase'
require 'term/ansicolor'
require 'helpers/app/Color_Puts'

require 'quietbacktrace'

class QuietBacktrace::BacktraceCleaner
  
  ALL_GEMS_SUB  = '/lib/ruby/gems' 
  ALL_NOISE << '/middleware'
  ALL_NOISE << '/tests/__helper__'
  ALL_NOISE << ALL_GEMS_SUB

  def body_clean(backtrace)
    total = backtrace.size
    brain = [backtrace[0]].compact
    head  = backtrace[1..3]     || []
    body  = backtrace[4..total] || []
    remove_first_slash( 
      filter(brain) + 
      filter(silence_all_gems(head)) + 
      filter(silence(body || []))
    ) 
  end
  alias_method :orig_clean, :clean
  alias_method :clean, :body_clean
  
  def silence_all_gems(backtrace)
    backtrace = backtrace.reject { |line| line[ALL_GEMS_SUB] }
    backtrace
  end
  
  def remove_first_slash(backtrace)
    backtrace.map { |line| 
      if line.lstrip[ /\A\// ]
        line.sub('/', '')
      else
        line
      end
    }
  end
  
end # === class


require 'megauni'
raise '$KCODE not set to UTF8 in start file.' unless $KCODE == 'UTF8'

include Color_Puts

puts_white " ===================================== "

at_exit do
  puts ''
end

class Test::Unit::TestResult
  # Returns a string contain the recorded runs, assertions,
  # failures and errors in this TestResult.
  def to_s_with_colors
    
    str = []
    str << "#{run_count} tests, "
    str << "#{assertion_count} assertions, "
    str << colorize_result(failure_count, "#{failure_count} failures, ")
    str << colorize_result(error_count, "#{error_count} errors, ")
    
    test_pass_count ||= run_count - failure_count - error_count

    txt = case test_pass_count
          when 0 
            'None passed '
          when 1
            test_pass_count == run_count ? 'It passes. ' : '1 test pass '
          when run_count
            'All pass :) '
          else
            "#{test_pass_count} tests pass "
          end

    str << colorize_green( txt )
    
    str.join
  end
  alias_method :to_s_wo_colors, :to_s
  alias_method :to_s, :to_s_with_colors

  def colorize_result count, msg
    if count != 0
      colorize_red msg
    else
      colorize_white msg
    end
  end
end


class Test::Unit::TestCase
  
  # Used to fix a minor minitest/unit incompatibility in flexmock
  # AssertionFailedError = Class.new(StandardError)
  
  def self.must_methods
    @must_methods ||= {}
  end

  def self.must(name, &block)
    test_name = "test_#{name.gsub(/[^a-z0-9\_]+/i,'_')}".to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
      must_methods[test_name] = caller[0]
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end

  # Since I am not smart enough to figure out how to right a 
  # custom Test::Unit::UI to catch empty tests, the following 
  # hack will do.
  # The following will raise a RuntimeError if an empty test, ( do...end ),
  # is found. If there was an error or failure, it will *not*
  # raise a RuntimeError.
  def run_and_raise_on_empty_test *args, &blok
    
    get_vals = lambda { |runner| [ runner.assertion_count, runner.error_count, runner.failure_count ] }
    orig     = get_vals.call(args.first)
    result   = run_wo_raise_on_empty_test(*args, &blok)
    latest   = get_vals.call(args.first)

    if orig == latest  
      msg = "Empty test: :#{method_name} in file: #{self.class.must_methods[method_name.to_sym]}"
      raise msg
    end
    
    result 
  end
  alias_method :run_wo_raise_on_empty_test, :run
  alias_method :run, :run_and_raise_on_empty_test
  
  # === Custom Helpers ===

  def self.admin_member
    @admin_member ||= Life.by_username("admin-member-1").owner
  end

  def self.regular_members
    @regular_mem ||= [1,2,3].map { |i| Life.by_username("regular-member-#{i}").owner }
  end
  
  [1,2,3].each do |i|
    eval %~
      def regular_member_#{i}
        self.class.regular_members[#{i}-1]
      end

      def regular_username_#{i}
        self.class.regular_members[#{i}-1].usernames.first
      end
      
      def regular_password_#{i}
        'regular-password'
      end
      
      def log_in_regular_member_#{i}
        mem = Life.by_username(regular_username_#{i}).owner
        assert_equal false, mem.has_power_of?( :ADMIN )
        post '/log-in/', {:username=>mem.usernames.first, :password=>regular_password_#{i}}, ssl_hash
        follow_redirect!
        assert_match( /lifes/, last_request.fullpath)
      end
    ~
  end

  def mem
    regular_member_1
  end

  def log_in_mem
    log_in_regular_member_1
  end

  def admin_member
    self.class.admin_member
  end

  def admin_username
    self.class.admin_member.data.lifes.first.last[:username]
  end

  def admin_password
    'admin-password'
  end

  def generate_random_member
    chars    = ('a'..'z').to_a + ('A'..'Z').to_a
    username = (1..5).to_a.inject('') { |m,l| m << chars[rand(chars.size)]; m } + "#{rand(100)}"
    password = "random-password-#{rand(1000)}"
    mem = Member.create(nil,
      :add_username => username ,
      :password => password,
      :confirm_password => password
    )
    [mem, username, password]
  end

  def utc_string
    Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')
  end

  def chop_last_2(str)
    if not str.is_a?(String)
      raise ArgumentError, "#{str.inspect} needs to be a String."
    end
    str[0, str.size - 2]
  end

  def ssl_hash
    {'HTTP_X_FORWARDED_PROTO' => 'https', 'rack.url_scheme'  => 'https' }
  end

  def last_response_should_be_xml
    assert_equal last_response.headers['Content-Type'], 'application/xml;charset=utf-8'
  end

  def follow_ssl_redirect!
    follow_redirect!
    follow_redirect!
  end

  def assert_raises_with_message( err_class, err_msg, &blok )
    err = assert_raises(err_class, &blok)
    case err_msg
    when String
      assert_equal err_msg, err.message
    when Regexp
      assert_match err_msg, err.message
    else
      raise ArgumentError, "Unknown class for error message: #{err_msg.inspect}"
    end
  end

  def assert_redirect(loc, status = 301)
    assert_equal loc, last_response.headers['Location'] 
    assert_equal status, last_response.status
  end

  def assert_last_response_ok
    assert_equal 200, last_response.status
  end

  def assert_log_out
    get '/lifes/'
    assert_redirect('/log-in/', 303)
  end

  def log_in_member(mem, password)
    assert_equal false, mem.has_power_of?( :ADMIN )
    post '/log-in/', {:username=>mem.usernames.first, :password=>password}, ssl_hash
    follow_redirect!
    assert_match( /lifes/, last_request.fullpath)
  end

  def log_in_admin
    mem = Life.by_username('admin-member-1').owner
    assert mem.has_power_of?(:ADMIN)
    post '/log-in/', {:username=>mem.usernames.first, :password=>admin_password}, ssl_hash
    follow_redirect!
    assert_match( /lifes/, last_request.fullpath )
  end

  def create_member raw_opts = {}
    
    opts = Data_Pouch.new(raw_opts, :password, :confirm_password, :add_username, :email)
    
    if !opts.add_username
      opts.add_username = "name#{rand(1000000)}"
    end
    
    if !opts.password && !opts.confirm_password
      new_pwrd              = "pass-#{opts.add_username}"
      opts.password         = new_pwrd
      opts.confirm_password = new_pwrd
    end
    
    if !opts.email
      opts.email = "test-#{rand(10000)}@megauni.com"
    end

    Member.create nil, opts.as_hash
  end

  def create_member_and_log_in(*args)
    mem = create_member(*args)
    log_in_member(mem, "pass-#{mem.usernames.first}")
    mem
  end

  def create_club(mem = nil, raw_club_opts = {})
    mem ||= regular_member_1
    id        = rand(20000).to_s + object_id.to_s
    defaults  = {:filename=>"#{id}", :title=>"Club: #{id}", 
                       :teaser=>"Teaser for: Club #{id}"}
    club_opts = defaults.update(raw_club_opts)
    club      = Club.create(mem, club_opts )
  end

  def create_message( mem, club = nil, un_id_or_opts = nil )
    
    club ||= self.club
    
    opts, un_id = case un_id_or_opts
                  when Hash
                    [ un_id_or_opts, nil ]
                  when BSON::ObjectID
                    [ {}, un_id_or_opts]
                  else
                    [ {}, nil ]
                  end

    final_opts = {
      :privacy => 'public',
      :target_ids => [club.data._id],
      :owner_id => (un_id || mem.username_ids.first),
      :body => "random body #{rand(4000)}",
      :message_model => 'random'
    }.update(opts)

    Message.create( mem, final_opts )
  end

  def create_club_content
    club_1 = create_club
    club_2 = create_club
    mess_1 = create_message(regular_member_1, club_1)
    mess_2 = create_message(regular_member_2, club_2)
    {:clubs => [club_1, club_2], :messages=>[mess_1, mess_2]}
  end

  def add_username mem = nil
    mem ||= regular_member_1
    un_2 = "rand_#{rand 3000}"
    Member.update(mem.data._id, mem, :add_username=>un_2)
    mem = Member.by_id(mem.data._id)
    uns     = mem.usernames
    un_ids  = uns.map { |u| mem.username_to_username_id(u) }
    [mem, uns, un_ids]
  end

  def club
    Club.by_id(Club.find_one({})['_id'])
  end

  
end

