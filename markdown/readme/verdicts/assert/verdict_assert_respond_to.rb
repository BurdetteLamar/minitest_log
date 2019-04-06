require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_respond_to.xml') do |log|
      log.verdict_assert_respond_to?(:one_id, 0, :succ, 'One message')
      log.verdict_assert_respond_to?(:another_id, 0, :empty?, 'Another message')
    end
  end
end
