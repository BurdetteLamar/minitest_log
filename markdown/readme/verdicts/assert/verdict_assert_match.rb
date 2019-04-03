require 'minitest_log'
class Example < Minitest::Test
  def test_verdict_assert_match
    MinitestLog.new('verdict_assert_match.xml') do |log|
      log.verdict_assert_match?(:match_id, /foo/, 'food', 'Match message')
      log.verdict_assert_match?(:not_match_id, /foo/, 'feed', 'Not match message')
    end
  end
end
