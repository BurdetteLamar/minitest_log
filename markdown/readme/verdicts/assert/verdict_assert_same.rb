require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_same.xml') do |log|
      log.verdict_assert_same?(:one_id, :foo, :foo, 'One message')
      log.verdict_assert_same?(:another_id, 'foo', 'foo', 'Another message')
    end
  end
end
