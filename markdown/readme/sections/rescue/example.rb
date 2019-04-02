require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('My rescued section', :rescue) do
        raise RuntimeError.new('Boo!')
        log.comment('This code will not be reached, because the section terminates.')
      end
      log.comment('This codew will be reached, because it is not in the terminated section.')
    end
  end
end
