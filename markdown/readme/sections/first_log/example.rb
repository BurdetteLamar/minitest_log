require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    # Open the log.
    MinitestLog.open do |log|
      log.section('Show off section functionality') do
        log.section('Name', 'The first argument becomes the section name.')
        log.section('Text', 'A String argument becomes text.')
        log.section('Nesting', 'Sections can nest.') do
          log.section('Outer', 'Outer section.') do
            log.section('Inner', 'Inner section.')
            log.section('Another','Another.')
          end
        end
        log.section('Childless', 'A section need not have children.')
        log.section('Attributes', {:a => 0, :b => 1}, 'A Hash becomes attributes.')
        log.section('Timestamp', :timestamp, 'Symbol :timestamp requests that the current time be logged.')
        log.section('Duration', :duration, 'Symbol :duration requests that the duration be logged .') do
          sleep(1)
        end
        log.section('Rescue', :rescue, 'Symbol :rescue, requests that any exception be rescued and logged.') do
          raise Exception.new('Oops!')
          log.comment('This comment will not be reached, because the test did not terminate.')
        end
        log.comment('This comment will be reached.')
        log.section(
            'Pot pourri',
            :duration,
            :timestamp,
            :rescue,
            {:a => 0, :b => 1},
            'A section can have lots of stuff.'
        )
      end
      # cdata, comment, put_element, put_data
      # Use nested sections to help organize the test code.
      log.section('Test some math methods') do
        log.section('Trigonometric') do
          # Use verdicts to verify values.
          log.verdict_assert_equal?('sine of 0.0', 0.0, Math::sin(0.0))
          # Use method :va_equal? as a shorthand alias for method :verdict_assert_equal?.
          log.va_equal?('cosine of 0.0', 1.0, Math::cos(0.0))
        end
        log.section('Exponentiation') do
          log.va_equal?('exp of 0.0', 1.0, Math::exp(0.0))
        end
      end
    end
  end
end
