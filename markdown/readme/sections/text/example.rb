require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open do |log|
      log.section('My section', 'Text') do
      end
      log.section('Another section', 'Text', ' and more text') do
      end
    end
  end

end
