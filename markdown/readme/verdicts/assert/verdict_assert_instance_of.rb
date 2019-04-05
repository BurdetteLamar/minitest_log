require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_instance_of.xml') do |log|
      log.verdict_assert_instance_of?(:one_id, String, 'my_string', 'One message')
      log.verdict_assert_instance_of?(:another_id, Integer, 'my_string', 'another message')
    end
  end
end
