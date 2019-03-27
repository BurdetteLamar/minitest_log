require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.open do |log|
      # Use nested sections to help organize the test code.
      log.section('Test some math methods') do
        log.section('Trig') do
          # Use verdicts to verify values.
          log.verdict_assert_equal?('sine of 0', 0, Math::sin(0))
          # Use method :va_equal? as a shorthand alias for method :verdict_assert_equal?.
          log.va_equal?('cosine of 0', 1, Math::cos(0))
        end
        log.section('Log') do
          log.va_equal?('exp of 0', 1, Math::exp(0))
        end
      end
    end
  end
end
