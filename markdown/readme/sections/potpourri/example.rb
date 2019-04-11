require 'minitest_log'
class Test < Minitest::Test
  def test_demo
    MinitestLog.new('log.xml') do |log|
      log.section(
          'Section with potpourri of arguments',
          # Not that you would ever want to do this. :-)
          :duration,
          'Word',
          {:a => 0, :b => 1},
          :timestamp,
          ' More words',
          {:c => 2, :d => 3},
          :rescue,
      ) do
        sleep(0.5)
        raise Exception.new('Boo!')
      end
    end
  end
end
