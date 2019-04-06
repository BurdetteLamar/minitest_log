require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_nil.xml') do |log|
      log.verdict_assert_nil?(:one_id, nil, 'One message')
      log.verdict_assert_nil?(:another_id, :a, 'Another message')
    end
  end
end
