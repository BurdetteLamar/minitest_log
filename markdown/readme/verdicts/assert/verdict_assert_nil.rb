require 'minitest_log'
class Example < Minitest::Test
  def test_verdict_assert_niil
    MinitestLog.new('verdict_assert_nil.xml') do |log|
      log.verdict_assert_nil?(:nil_id, [], 'Nil message')
      log.verdict_assert_nil?(:not_nil_id, [:a], 'Not nil message')
    end
  end
end
