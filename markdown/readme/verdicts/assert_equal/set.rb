require 'minitest_log'

class Example < Minitest::Test

  def test_example
    MinitestLog.new('set_log.xml') do |log|
      expected = Set.new([:a, :b, :c, :d])
      actual = Set.new([:c, :d, :e, :f])
      log.verdict_assert_equal?(:analyzed, expected, actual)
    end
  end

end
