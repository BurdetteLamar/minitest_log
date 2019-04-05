require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_equal.xml') do |log|
      log.verdict_assert_equal?(:one_id, 0, 0, 'One message')
      log.verdict_assert_equal?(:another_id, 0, 1, 'Another message')
    end
  end
end
