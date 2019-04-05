require 'set'
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('each_with_index.xml') do |log|
      log.section('Objects logged using :each_with_index') do
        log.section('Array') do
          array = %w/apple orange peach banana strawberry pear/
          log.put_data('My array', array)
        end
        log.section('Set') do
          set = Set.new(%w/baseball football basketball hockey/)
          puts set.respond_to?(:each_with_index)
          log.put_data('My set', set)
        end
      end
    end
  end
end
