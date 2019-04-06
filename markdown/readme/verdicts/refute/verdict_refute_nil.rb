require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_nil.xml') do |log|
      log.verdict_refute_nil?(:one_id, :a, 'One message')
      log.verdict_refute_nil?(:another_id, nil, 'Another message')
    end
  end
end
