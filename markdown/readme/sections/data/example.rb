require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('My data section') do
        string = "When you come to a fork in the road, take it. -- Yogi Berra"
        hash = {
            :name => 'Ichabod Crane',
            :address => '14 Main Street',
            :city => 'Sleepy Hollow',
            :state => 'NY',
            :zipcode => '10591',
        }
        array = %w/apple orange peach banana strawberry pear/
        log.put_data('My string', string)
        log.put_data('My hash', hash)
        log.put_data('My array', array)
      end
    end
  end
end
