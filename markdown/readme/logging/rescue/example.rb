require 'minitest/autorun'
require 'test_log'

class Example < MiniTest::Test

  def test_example
    TestLog.open(self) do |log|
      log.section('My section', :rescue) do
        raise RuntimeError.new('Boo!')
      end
    end
  end

end
