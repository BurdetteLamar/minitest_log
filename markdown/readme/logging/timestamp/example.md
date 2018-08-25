## Duration

This example shows how to put an execution duration onto a section.

```example.rb```:
```ruby
require 'minitest/autorun'
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open(self) do |log|
      log.section('My section', :duration) do
        sleep 3
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
  <section name='My section' duration_seconds='3.000'/>
</log>
```
