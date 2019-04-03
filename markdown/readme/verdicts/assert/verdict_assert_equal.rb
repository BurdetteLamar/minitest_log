require 'minitest_log'
class Example < Minitest::Test
  def test_verdict_assert_equal
    MinitestLog.new('verdict_assert_equal.xml') do |log|
      log.verdict_assert_equal?(:equal_id, 0, 0, 'Equal message')
      log.verdict_assert_equal?(:not_equal_id, 0, 1, 'Not equal message')
    end
  end
end
