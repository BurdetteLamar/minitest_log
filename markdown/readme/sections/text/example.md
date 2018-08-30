## Duration

This example shows how to put text onto a section.

```example.rb```:
```ruby
require 'minitest/autorun'
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open(self) do |log|
      log.section('My section', 'Text') do
      end
      log.section('Another section', 'Text', ' and more text') do
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
  <section name='My section'>
    Text
  </section>
  <section name='Another section'>
    Text and more text
  </section>
</log>
```
