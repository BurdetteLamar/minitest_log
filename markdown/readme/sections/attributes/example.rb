require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open do |log|
      attrs = {:first_attr => 'first', :second_attr => 'second'}
      log.section('My section', attrs) do
      end
      more_attrs = {:third_attr => 'third'}
      log.section('Another section', attrs, more_attrs) do
      end
    end
  end

end
