require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open do |log|
      log.section('My section', :rescue) do
        raise RuntimeError.new('Boo!')
      end
    end
  end

end
