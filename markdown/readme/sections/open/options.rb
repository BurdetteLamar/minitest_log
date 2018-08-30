require 'minitest/autorun'
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    options = {
        :file_path => 'my_log.xml',
        :root_name => 'my_root_name',
        :xml_indentation => 4,
    }
    MinitestLog.open(options) do |log|
      # Test stuff goes here.
    end
  end

end
