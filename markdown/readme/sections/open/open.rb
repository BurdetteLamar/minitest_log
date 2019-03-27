require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.open do |log|
      log.comment('Test stuff goes here.')
    end
  end
end
