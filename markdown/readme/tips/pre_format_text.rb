require 'minitest_log'
class Test < Minitest::Test
  def test_demo
    MinitestLog.new('pre_format_text.xml') do |log|
      log.section('My section', 'Pre-formatted text without surrounding newlines.  Not so pretty.') do
        text = <<EOT
This is a multi-line, pre-formatted text passage.
Here, we have added no extra newlines,
so the text is not separated from the enclosing square brackets.
EOT
        log.put_cdata(text)
      end
      log.section('Another section', 'Pre-formatted text with surrounding newlines.  Prettier.') do
        text = <<EOT

This is a multi-line, pre-formatted text passage.
Here, we have added newlines at the beginning and end,
so the text is separated from the enclosing square brackets.

EOT
        log.put_cdata(text)
      end
    end
  end
end
