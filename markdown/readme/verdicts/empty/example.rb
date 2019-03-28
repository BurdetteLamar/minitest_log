require 'minitest_log'

class Example < Minitest::Test

  def test_example
    MinitestLog.new('log.xml') do |log|
      log.verdict_assert_empty?(:first_verdict_id, [], 'My message')
      log.verdict_refute_empty?(:second_verdict_id, [0], 'My message')
    end
  end

end
