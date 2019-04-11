require 'minitest_log'
class Test < Minitest::Test
  def test_demo
    MinitestLog.new('no_summary.xml') do |log|
      log.section('This log has no summary.') do
        populate_the_log(log)
      end
    end
    MinitestLog.new('summary.xml', :summary => true) do |log|
      log.section('This log has a summary.') do
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
