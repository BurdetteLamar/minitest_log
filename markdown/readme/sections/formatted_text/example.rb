require 'minitest_log'
class Example < MiniTest::Test

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
