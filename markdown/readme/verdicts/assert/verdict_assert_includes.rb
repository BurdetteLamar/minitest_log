require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_includes.xml') do |log|
      log.verdict_assert_includes?(:one_id, [:a, :b, :c], :b, 'One message')
      log.verdict_assert_includes?(:another_id, [:a, :b, :c], :d, 'Another message')
    end
  end
end
