require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('kind_of_string.xml') do |log|
      log.section('Objects that are a kind_of?(String)') do
        string = 'When you come to a fork in the road, take it. -- Yogi Berra'
        log.put_data('My string', string)
      end
    end
  end
end
