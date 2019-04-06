require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_raises.xml') do |log|
      log.verdict_assert_raises?(:one_id, RuntimeError, 'One message') do
        raise RuntimeError.new('Boo!')
      end
      log.verdict_assert_raises?(:another_id, RuntimeError, 'Another message') do
        raise Exception.new('Boo!')
      end
    end
  end
end
