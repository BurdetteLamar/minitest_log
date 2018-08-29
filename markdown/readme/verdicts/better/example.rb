require 'minitest_log'

class Example < Minitest::Test

  def test_example
    MinitestLog.open do |log|
      expected = {:a => 0, :b => 1, :c => 2, :d => 3, :e => 4, :f => 5}
      actual = {:h => 5, :g => 4, :d => 1, :c => 0, :b => 1, :a => 0}
      log.verdict_assert_equal?(:analyzed, expected, actual)
    end
  end

end
