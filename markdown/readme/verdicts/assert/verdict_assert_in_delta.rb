require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_in_delta.xml') do |log|
      log.verdict_assert_in_delta?(:one_id, 0, 0, 1, 'One message')
      log.verdict_assert_in_delta?(:another_id, 0, 1, 2, 'Another message')
    end
  end
end
