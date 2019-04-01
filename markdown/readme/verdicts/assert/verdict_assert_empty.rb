require 'minitest_log'
class Example < Minitest::Test
  def test_verdict_assert
    MinitestLog.new('verdict_assert_empty.xml') do |log|
      log.verdict_assert_empty?(:empty_id, true, 'Empty message')
      log.verdict_assert_empty?(:not_empty_id, false, 'Not empty message')
    end
  end
end
