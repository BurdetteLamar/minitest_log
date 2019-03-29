require 'set'
require 'uri'
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('Built-in classes') do
        log.section('String') do
          string = "When you come to a fork in the road, take it. -- Yogi Berra"
          log.put_data('My string', string)
        end
        log.section('Objects logged using :each_pair') do
          hash = {
              :name => 'Ichabod Crane',
              :address => '14 Main Street',
              :city => 'Sleepy Hollow',
              :state => 'NY',
              :zipcode => '10591',
          }
          Struct.new('Foo', :x, :y, :z)
          foo = Struct::Foo.new(0, 1, 2)
          log.put_data('My hash', hash)
          log.put_data('My struct', foo)
        end
        log.section('Objects logged using :each_with_index') do
          array = %w/apple orange peach banana strawberry pear/
          set = Set.new(array)
          dir = Dir.new(File.dirname(__FILE__ ))
          log.put_data('My array', array)
          log.put_data('My set', set)
          log.put_data('My directory', dir)
        end
        log.section('Objects logged using :to_s') do
          log.put_data('My integer', 0)
          log.put_data('My exception', Exception.new('Boo!'))
          log.put_data('My regexp', 'Bar')
          log.put_data('My time', Time.now)
          log.put_data('My uri,', URI('https://www.github.com'))
        end
      end
    end
  end
end
