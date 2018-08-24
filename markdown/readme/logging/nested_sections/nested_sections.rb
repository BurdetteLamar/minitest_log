require 'minitest/autorun'
require 'test_log'

class Example < MiniTest::Test

  def test_example
    TestLog.open(self) do |log|
      log.section('First outer') do
        log.section('First inner') do
        end
        log.section('Second inner') do
        end
      end
      log.section('Second outer') do
        log.section('First inner') do
        end
        log.section('Second inner') do
        end
      end
    end
  end

end
