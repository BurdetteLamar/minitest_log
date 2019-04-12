require 'minitest_log'
class Example < Minitest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('Custom elements with no children') do
        log.put_element('childless_element')
        log.put_element('childless_element_with_text', 'Text for this element.')
        log.put_element('childless_element_with_attributes', {:a => 0, :b => 1})
      end
      log.section('Custom elements with children') do
        log.put_element('parent_element') do
          log.put_element('child_element')
        end
        log.put_element('parent_element_with_text', 'Text for this element.') do
          log.put_element('child_element')
        end
        log.put_element('parent_element_with_attributes', {:a => 0, :b => 1}) do
          log.put_element('child_element')
        end
      end
    end
  end
end
