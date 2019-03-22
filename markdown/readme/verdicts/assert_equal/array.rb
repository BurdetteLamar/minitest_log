require 'minitest_log'

class Example < Minitest::Test

  def test_example
    MinitestLog.open('array_log.xml') do |log|
      expected = [:a, :b, :c, :d, :e, :f, :k, :l, :m, :n]
      actual = [:a, :b, :g, :h, :c, :d, :i, :j, :k, :l]
      log.verdict_assert_equal?(:analyzed, expected, actual)
    end
  end

end
