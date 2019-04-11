require 'minitest_log'
class Test < Minitest::Test
  def test_demo
    MinitestLog.new('no_error_verdict.xml') do |log|
      log.section('This log has no error verdict.') do
        populate_the_log(log)
      end
    end
    MinitestLog.new('error_verdict.xml', :error_verdict => true) do |log|
      log.section('This log has an error verdict.') do
        populate_the_log(log)
      end
    end
  end
  def populate_the_log(log)
    log.verdict_assert?(:pass, true)
    log.verdict_assert?(:fail, false)
    log.section('My error-producing section', :rescue) do
      raise Exception.new('Boo!')
    end
  end
end
