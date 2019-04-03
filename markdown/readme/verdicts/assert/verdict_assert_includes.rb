require 'minitest_log'
class Example < Minitest::Test
  def test_verdict_assert_includes
    MinitestLog.new('verdict_assert_includes.xml') do |log|
      log.verdict_assert_includes?(:includes_id, [:a, :b, :c], :b, 'Included message')
      log.verdict_assert_includes?(:not_includes_id, [:a, :b, :c], :d, 'Not included message')
    end
  end
end
