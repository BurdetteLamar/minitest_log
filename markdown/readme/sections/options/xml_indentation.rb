require 'minitest_log'
class Test < Minitest::Test
  def test_demo
    MinitestLog.new('default_xml_indentation.xml') do |log|
      log.section('This log has the default XML indentation (2 spaces).') do
        log.section('See?')
      end
    end
    MinitestLog.new('xml_indentation_0.xml', :xml_indentation => 0) do |log|
      log.section('This log has an XML indentation of 0 (no indentation).') do
        log.section('See?')
      end
    end
    MinitestLog.new('xml_indentation_-1.xml', :xml_indentation => -1) do |log|
      log.section('This log has an XML indentation of -1 (all on one line).') do
        log.section('See?')
      end
    end
  end
end
