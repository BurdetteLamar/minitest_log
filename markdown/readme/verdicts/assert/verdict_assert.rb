require 'minitest_log'
class Example < Minitest::Test
  def test_verdict_assert
    MinitestLog.new('verdict_assert.xml') do |log|
      log.verdict_assert?(:true_id, true, 'True message')
      log.verdict_assert?(:false_id, false, 'False message')
    end
  end
end