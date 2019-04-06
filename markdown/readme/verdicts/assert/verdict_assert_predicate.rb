require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_predicate.xml') do |log|
      log.verdict_assert_predicate?(:one_id, '', :empty?, 'One message')
      log.verdict_assert_predicate?(:another_id, 'x', :empty?, 'Another message')
    end
  end
end
