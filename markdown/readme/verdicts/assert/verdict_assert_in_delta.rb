require 'minitest_log'
class Example < Minitest::Test
  def test_verdict_assert
    MinitestLog.new('verdict_assert_in_delta.xml') do |log|
      log.verdict_assert_in_delta?(:in_delta_id, 0, 0, 1, 'In delta message')
      log.verdict_assert_in_delta?(:not_in_delta_id, 0, 1, 2, 'Not in delta message')
    end
  end
end
