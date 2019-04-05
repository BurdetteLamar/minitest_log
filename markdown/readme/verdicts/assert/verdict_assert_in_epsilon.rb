require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verrdict
    MinitestLog.new('verdict_assert_in_epsilon.xml') do |log|
      log.verdict_assert_in_epsilon?(:one_id, 3, 2, 1, 'One message')
      log.verdict_assert_in_epsilon?(:another_id, 3, 2, 0, 'Another message')
    end
  end
end
