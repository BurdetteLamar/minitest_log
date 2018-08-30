require 'minitest_log'

class Example < Minitest::Test

  def test_example
    MinitestLog.open do |log|
      log.verdict_assert_equal?(:my_verdict_id, 'Lorem ipsum', 'Lorem ipsum')
    end
  end

end
