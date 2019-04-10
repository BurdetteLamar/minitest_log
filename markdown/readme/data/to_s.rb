require 'uri'
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('to_s.xml') do |log|
      log.section('Objects logged using :to_s') do
        log.put_data('My integer', 0)
        log.put_data('My exception', Exception.new('Boo!'))
        log.put_data('My regexp', /Bar/)
        log.put_data('My time', Time.now)
        log.put_data('My uri,', URI('https://www.github.com'))
      end
    end
  end
end
