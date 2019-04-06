require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_operator.xml') do |log|
      log.verdict_refute_operator?(:one_id, 5, :<=, 4, 'One message')
      log.verdict_refute_operator?(:another_id, 3, :<=, 4, 'Another message')
    end
  end
end
