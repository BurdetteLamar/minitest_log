require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_equal.xml') do |log|
      log.verdict_refute_equal?(:one_id, 0, 1, 'One message')
      log.verdict_refute_equal?(:another_id, 0, 0, 'Another message')
    end
  end
end
