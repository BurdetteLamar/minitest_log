require 'minitest_log'

class Example < Minitest::Test

  def test_example
    MinitestLog.open do |log|
      log.verdict_assert?(:first_verdict_id, false, 'My message')
      log.verdict_refute?(:second_verdict_id, false, 'My message')
    end
  end

end
