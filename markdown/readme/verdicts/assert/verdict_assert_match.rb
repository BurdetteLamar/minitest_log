require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_match.xml') do |log|
      log.verdict_assert_match?(:one_id, /foo/, 'food', 'One message')
      log.verdict_assert_match?(:another_id, /foo/, 'feed', 'Another message')
    end
  end
end
