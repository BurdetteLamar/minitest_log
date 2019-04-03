require 'minitest_log'
class Example < Minitest::Test
  def test_verdict_assert_kind_of
    MinitestLog.new('verdict_assert_kind_of.xml') do |log|
      log.verdict_assert_kind_of?(:kind_of_id, Numeric, 1.0, 'Kind of message')
      log.verdict_assert_kind_of?(:not_kind_of_id, String, 1.0, 'Not kind of message')
    end
  end
end
