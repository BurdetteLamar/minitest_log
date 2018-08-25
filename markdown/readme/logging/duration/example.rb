require 'minitest/autorun'
require 'test_log'

class Example < MiniTest::Test

  def test_example
    TestLog.open(self) do |log|
      log.section('My section', :duration) do
        sleep 3
      end
    end
  end

end
