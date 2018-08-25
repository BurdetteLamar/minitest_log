require 'minitest/autorun'
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open(self) do |log|
      log.section('My section', :rescue) do
        raise RuntimeError.new('Boo!')
      end
    end
  end

end
