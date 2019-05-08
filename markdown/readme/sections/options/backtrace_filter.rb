require 'minitest_log'
class Test < Minitest::Test
  def test_demo
    MinitestLog.new('default_backtrace_filter.xml') do |log|
      fail 'Boo!'
    end
    MinitestLog.new('custom_backtrace_filter.xml', :backtrace_filter => /xxx/) do |log|
      fail 'Boo!'
    end
  end
end
