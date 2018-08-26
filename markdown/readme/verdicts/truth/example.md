## Truth

This example shows how assert and refute truthiness.

```example.rb```:
```ruby
require 'minitest_log'

class Example < Minitest::Test

  def test_example
    MinitestLog.open do |log|
      log.verdict_assert?(:first_verdict_id, false, 'My message')
      log.verdict_refute?(:second_verdict_id, false, 'My message')
    end
  end

end
```

In the call to method ```log.verdict_assert?```, the three arguments are:

- A ```Symbol``` verdict identifier.
- An truth value ```Object``` to be verified.
- An optional ```String``` message.

The method tests whether the valus is truthy, logs the verdict, and  returns a boolean, in this case ```true```.

The call to method ```log.verdict_assert?```, is similar, but tests whether the value is not truthy.

Here's the log showing the verdicts:

```log.xml```:
```xml
<log>
  <summary verdicts='2' failures='1' errors='0'/>
  <verdict method='verdict_assert?' outcome='failed' id='first_verdict_id' message='My message'>
    <act_value>
      false
    </act_value>
    <exception class='Minitest::Assertion'>
      <message>
        Expected false to be truthy.
      </message>
      <backtrace>
        <![CDATA[
example.rb:7:in `block in test_example'
example.rb:6:in `test_example']]>
      </backtrace>
    </exception>
  </verdict>
  <verdict method='verdict_refute?' outcome='passed' id='second_verdict_id' message='My message'>
    <act_value>
      false
    </act_value>
  </verdict>
</log>
```

