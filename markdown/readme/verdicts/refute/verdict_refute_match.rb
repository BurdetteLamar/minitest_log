require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_match.xml') do |log|
      log.verdict_refute_match?(:one_id, /foo/, 'feed', 'One message')
      log.verdict_refute_match?(:another_id, /foo/, 'food', 'Another message')
    end
  end
end
