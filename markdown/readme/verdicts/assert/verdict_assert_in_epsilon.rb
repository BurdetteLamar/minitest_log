require 'minitest_log'
class Example < Minitest::Test
  def test_verdict_assert
    MinitestLog.new('verdict_assert_in_epsilon.xml') do |log|
      log.verdict_assert_in_epsilon?(:in_epsilon_id, 3, 2, 1, 'In epsilon message')
      log.verdict_assert_in_epsilon?(:not_in_epsilon_id, 3, 2, 0, 'Not in epsilon message')
    end
  end
end
