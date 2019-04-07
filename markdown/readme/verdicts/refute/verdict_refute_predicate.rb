require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_predicate.xml') do |log|
      log.verdict_refute_predicate?(:one_id, 'x', :empty?, 'One message')
      log.verdict_refute_predicate?(:another_id, '', :empty?, 'Another message')
    end
  end
end
