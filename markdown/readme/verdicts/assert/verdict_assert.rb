require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert.xml') do |log|
      log.verdict_assert?(:one_id, true, 'One message')
      log.verdict_assert?(:another_id, false, 'Another message')
    end
  end
end
