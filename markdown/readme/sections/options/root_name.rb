require 'minitest_log'
class Test < Minitest::Test
  def test_demo
    MinitestLog.new('default_root_name.xml') do |log|
      log.section('This log has the default root name.')
    end
    MinitestLog.new('custom_root_name.xml', :root_name => 'my_root_name') do |log|
      log.section('This log has a custom root name.')
    end
  end
end
