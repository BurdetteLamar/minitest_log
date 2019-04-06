require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_empty.xml') do |log|
      log.verdict_refute_empty?(:one_id, [:a], 'One message')
      log.verdict_refute_empty?(:another_id, [], 'Another message')
    end
  end
end
