require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_includes.xml') do |log|
      log.verdict_refute_includes?(:one_id, [:a, :b, :c], :d, 'One message')
      log.verdict_refute_includes?(:another_id, [:a, :b, :c], :b, 'Another message')
    end
  end
end
