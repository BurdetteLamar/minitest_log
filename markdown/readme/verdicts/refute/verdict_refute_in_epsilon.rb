require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_in_epsilon.xml') do |log|
      log.verdict_refute_in_epsilon?(:one_id, 3, 2, 0, 'One message')
      log.verdict_refute_in_epsilon?(:another_id, 3, 2, 1, 'Another message')
    end
  end
end
