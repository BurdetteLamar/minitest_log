require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    options = {
        :root_name => 'my_root_name',
        :xml_indentation => 4,
    }
    MinitestLog.open('my_log.xml', options) do |log|
      log.comment('Test code goes here.')
    end
  end

end
