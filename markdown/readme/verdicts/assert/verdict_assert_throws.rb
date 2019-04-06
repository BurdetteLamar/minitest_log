require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_throws.xml') do |log|
      log.verdict_assert_throws?(:one_id, :foo, 'One message') do
        throw :foo
      end
      log.verdict_assert_throws?(:another_id, :foo, 'Another message') do
        throw :bar
      end
    end
  end
end
