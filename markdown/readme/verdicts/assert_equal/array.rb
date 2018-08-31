require 'minitest_log'

class Example < Minitest::Test

  def test_example
    MinitestLog.open(:file_path => 'array_log.xml') do |log|
      expected = [:a, :b, :c, :d, :e, :f]
      actual = [:a, :b, :g, :h, :c, :d, :i, :j]
      log.verdict_assert_equal?(:analyzed, expected, actual)
    end
  end

end
