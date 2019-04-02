require 'minitest_log'
class Example < Minitest::Test
  def test_verdict_assert_empty
    MinitestLog.new('verdict_assert_empty.xml') do |log|
      log.verdict_assert_empty?(:empty_id, [], 'Empty message')
      log.verdict_assert_empty?(:not_empty_id, [:a], 'Not empty message')
    end
  end
end
