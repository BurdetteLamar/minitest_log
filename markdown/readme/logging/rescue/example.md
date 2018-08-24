## Rescue

This example shows how to rescue an exception in a section.

```example.rb```:
```ruby
require 'minitest/autorun'
require 'test_log'

class Example < MiniTest::Test

  def test_example
    TestLog.open(self) do |log|
      log.section('My section', :rescue) do
        raise RuntimeError.new('Boo!')
      end
    end
  end

end
```

The log:

```log.xml```:
```xml
<log>
  <summary verdicts='0' failures='0' errors='1'/>
  <section name='My section'>
    <uncaught_exception>
      <verdict_id>
        My section
      </verdict_id>
      <class>
        RuntimeError
      </class>
      <message>
        Boo!
      </message>
      <backtrace>
        <![CDATA[
example.rb:9:in `block (2 levels) in test_example'
example.rb:8:in `block in test_example'
example.rb:7:in `test_example']]>
      </backtrace>
    </uncaught_exception>
  </section>
</log>
```
