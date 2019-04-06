require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_output.xml') do |log|
      log.verdict_assert_output?(:one_id, stdout = 'Foo', stderr = 'Bar') do
        $stdout.write('Foo')
        $stderr.write('Bar')
      end
      log.verdict_assert_output?(:another_id, stdout = 'Bar', stderr = 'Foo') do
        $stdout.write('Foo')
        $stderr.write('Bar')
      end
    end
  end
end
