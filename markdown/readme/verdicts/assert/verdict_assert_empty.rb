require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_empty.xml') do |log|
      log.verdict_assert_empty?(:one_id, [], 'One message')
      log.verdict_assert_empty?(:another_id, [:a], 'Another message')
    end
  end
end
