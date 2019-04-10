require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('My nested sections', 'Sections can nest.') do
        log.section('Outer', 'Outer section.') do
          log.section('Mid', 'Mid-level section') do
            log.section('Inner', 'Inner section.')
            log.section('Another','Another inner section.')
          end
        end
      end
    end
  end
end
