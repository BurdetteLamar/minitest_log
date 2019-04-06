require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_in_delta.xml') do |log|
      log.verdict_refute_in_delta?(:one_id, 0, 2, 1, 'One message')
      log.verdict_refute_in_delta?(:another_id, 0, 0, 1, 'Another message')
    end
  end
end
