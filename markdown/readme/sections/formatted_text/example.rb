require 'minitest_log'
class Example < MiniTest::Test

  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('Line of text with leading and trailing whitespace') do
        log.put_pre('  Text.  ')
      end
      text = <<EOT
Text
and
more
text.
EOT
      log.section('Multiline text with enhanced whitespace') do
        log.put_pre(text)
      end
      log.section('Multiline text without without enhanced whitespace') do
        log.put_pre(text, verbatim = true)
      end
    end
  end
end
