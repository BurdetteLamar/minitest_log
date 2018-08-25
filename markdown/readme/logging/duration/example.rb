require 'minitest/autorun'
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open(self) do |log|
      log.section('My section', :duration) do
        sleep 3
      end
    end
  end

end
