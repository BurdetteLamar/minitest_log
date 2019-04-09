require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_instance_of.xml') do |log|
      log.verdict_refute_instance_of?(:one_id, Integer, 'my_string', 'One message')
      log.verdict_refute_instance_of?(:another_id, String, 'my_string', 'another message')
    end
  end
end
