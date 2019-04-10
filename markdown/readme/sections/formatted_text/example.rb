require 'minitest_log'
class Example < MiniTest::Test

  def some_text_to_put
    [
        '  This line has leading whitespace that is preserved.',
        '',
        'The empty line above is preserved.',
        '  ',
        'The whitespace-only line above is preserved.',
        'This line has trailing whitespace that is preserved.  ',
    ].join("\n")
  end

  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('My section') do
        log.put_cdata(some_text_to_put)
      end
      log.section('Another section', 'Adding my own whitespace to separate first and last lines from enclosing square brackets.') do
        log.put_cdata("\n#{some_text_to_put}\n")
      end
    end
  end
end
