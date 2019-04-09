require 'minitest_log'
class Test < Minitest::Test
  def test_demo
    MinitestLog.new('pre_format_text.xml') do |log|
      text = <<EOT
      
This is a multi-line, pre-formatted text passage
  that has some unusual whitespace.   
(The preceding line has both leading and trailing whitespace.)

EOT
      log.put_cdata(text)
    end
  end
end