## Duration

This example shows how to put an atttributes onto a section.

```example.rb```:
```ruby
require 'minitest/autorun'
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open(self) do |log|
      attrs = {:first_attr => 'first', :second_attr => 'second'}
      log.section('My section', attrs) do
      end
      more_attrs = {:third_attr => 'third'}
      log.section('Another section', attrs, more_attrs) do
      end
    end
  end

end
```

The log:

```log.xml```:
```xml
<log>
  <summary verdicts='0' failures='0' errors='0'/>
  <section name='My section' first_attr='first' second_attr='second'/>
  <section name='Another sections' first_attr='first' second_attr='second' third_attr='third'/>
</log>
```
