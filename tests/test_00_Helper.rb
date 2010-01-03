require 'tests/__helper__'


class Test_The_Helper < Test::Unit::TestCase

	must 'raise a RuntimeError if a test is empty' do
		msg    = ":in `run': Empty test: :test_be_an_empty_test in file: tests/__test_The_Helper__1.rb:6 (RuntimeError)"
		output = `ruby tests/__test_The_Helper__1.rb 2>&1`
		assert_equal msg, output[msg]
	end

	must 'not raise anything if a test has an error' do
		msg  = "\n\n1 tests, 0 assertions, \e[37m\e[1m0 failures, \e[0m\e[0m\e[31m\e[1m1 errors\e[0m\e[0m\n"
		output = `ruby tests/__test_The_Helper__2.rb`
		assert_equal msg, output[msg]
	end

	must 'not raise anything if a test has an assertion fail.' do
		msg  = "\n\n1 tests, 1 assertions, \e[31m\e[1m1 failures, \e[0m\e[0m\e[37m\e[1m0 errors\e[0m\e[0m\n"
		output = `ruby tests/__test_The_Helper__3.rb`
		assert_equal msg, output[msg]
	end

end # === class Helper
