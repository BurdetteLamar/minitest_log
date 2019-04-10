require 'minitest_log'
class Example < MiniTest::Test

  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('Text with leading and trailing whitespace') do
        log.put_pre('  Text.  ')
      end
      text = <<EOT
Text
and
more
text.
EOT
      log.section('Multiline text with surrounding newlines') do
        log.put_pre(text)
      end
      log.section('Multiline text without surrounding newlines') do
        log.put_pre(text, verbatim = true)
      end
    end
  end
end
