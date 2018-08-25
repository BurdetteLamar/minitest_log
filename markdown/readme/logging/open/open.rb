require 'minitest/autorun'
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open(self) do |log|
      # Test stuff goes here.
    end
  end

end
