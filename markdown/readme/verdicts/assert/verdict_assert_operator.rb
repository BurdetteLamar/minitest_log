require 'minitest_log'
class Example < Minitest::Test
  def test_verdict_assert_operator
    MinitestLog.new('verdict_assert_operator.xml') do |log|
      log.verdict_assert_operator?(:operator_id, 3, :<=, 4, 'Message')
      log.verdict_assert_operator?(:not_operator_id, 5, :<=, 4, 'Message')
    end
  end
end
