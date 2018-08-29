require 'minitest_log'

class Example < Minitest::Test

  def test_example
    MinitestLog.open do |log|
      log.verdict_assert?(:assert_true, true)
      log.verdict_assert?(:assert_false, false)
    end
  end

end
