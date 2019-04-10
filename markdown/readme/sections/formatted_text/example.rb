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
      log.section('Text with leading and trailiing whitespace') do
        log.put_cdata('  Text.  ')
      end
      log.section('Multiline text') do
        text = <<EOT
Text
and
more
text.
EOT
        log.put_cdata(text)
      end
    end
  end
end
