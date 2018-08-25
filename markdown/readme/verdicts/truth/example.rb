require 'minitest/autorun'
require 'test_log'

class Example < MiniTest::Test

  def test_example
    TestLog.open(self) do |log|
      log.verdict_assert?(:first_verdict_id, true, 'My message')
      log.verdict_refute?(:second_verdict_id, false, 'My message')
    end
  end

end
