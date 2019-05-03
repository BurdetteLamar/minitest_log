require 'minitest_log'
class Example < Minitest::Test
  def test_example
    MinitestLog.new('each_pair.xml') do |log|
      log.section('Objects logged using :each_pair') do
        log.section('Hash') do
          hash = {
              :name => 'Ichabod Crane',
              :address => '14 Main Street',
              :city => 'Sleepy Hollow',
              :state => 'NY',
              :zipcode => '10591',
          }
          log.put_data('My hash', hash)
        end
        log.section('Struct') do
          Struct.new('Foo', :x, :y, :z)
          foo = Struct::Foo.new(0, 1, 2)
          log.put_data('My struct', foo)
        end
      end
    end
  end
end
