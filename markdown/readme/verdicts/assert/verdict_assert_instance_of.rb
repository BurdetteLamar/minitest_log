require 'minitest_log'
class Example < Minitest::Test
  def test_verdict_assert_instance_of
    MinitestLog.new('verdict_assert_instance_of.xml') do |log|
      log.verdict_assert_instance_of?(:instance_of_id, String, 'my_string', 'Instance of message')
      log.verdict_assert_instance_of?(:not_instance_of_id, Integer, 'my_string', 'Not instance of message')
    end
  end
end
