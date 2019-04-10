require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      text = <<EOT
  This line has leading whitespace that's preserved.

The empty line above is also preserved.
This line has trailing whitespace that's preserved.
EOT
      log.section('My section') do
        log.put_cdata(text)
      end
      log.section('Another section', 'Adding my own whitespace to separate first and last lines from enclosing square brackets.') do
        log.put_cdata("\n#{text}\n")
      end
    end
  end
end
