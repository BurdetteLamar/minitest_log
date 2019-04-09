require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_respond_to.xml') do |log|
      log.verdict_refute_respond_to?(:one_id, 0, :empty?, 'One message')
      log.verdict_refute_respond_to?(:another_id, 0, :succ, 'Another message')
    end
  end
end
