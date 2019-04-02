require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('My unrescued section') do
        raise RuntimeError.new('Boo!')
      end
      log.comment('This code will not be reached, because the test terminated.')
    end
  end
end
