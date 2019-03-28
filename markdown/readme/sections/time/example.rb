require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('My section with timestamp', :timestamp, 'Section with timestamp.')
      log.section('My section with duration', :duration, 'Section with duration.') do
        sleep(0.5)
      end
      log.section('My section with booth', :duration, :timestamp, 'Section with both.') do
        sleep(0.5)
      end
    end
  end
end
