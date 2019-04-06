require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_silent.xml') do |log|
      log.verdict_assert_silent?(:one_id) do
      end
      log.verdict_assert_silent?(:another_id) do
        $stdout.write('Foo')
      end
    end
  end
end
