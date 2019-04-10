require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('My section', 'Text for my section.') do
        log.section('Another section', 'Text for another section.', ' More text.')
      end
    end
  end
end
