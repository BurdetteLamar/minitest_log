require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.open do |log|
      log.section('My section', :duration) do
        sleep 3
      end
    end
  end
end
