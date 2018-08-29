require 'minitest_log'

class Example < Minitest::Test

  def test_example
    MinitestLog.open do |log|
      log.verdict_refute?(:refute_false, false)
      log.verdict_refute?(:refute_true, true)
    end
  end

end
