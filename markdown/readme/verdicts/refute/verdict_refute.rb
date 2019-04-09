require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute.xml') do |log|
      log.verdict_refute?(:one_id, false, 'One message')
      log.verdict_refute?(:another_id, true, 'Another message')
    end
  end
end
