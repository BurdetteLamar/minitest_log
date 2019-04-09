require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_kind_of.xml') do |log|
      log.verdict_refute_kind_of?(:one_id, String, 1.0, 'One message')
      log.verdict_refute_kind_of?(:another_id, Numeric, 1.0, 'Another message')
    end
  end
end
