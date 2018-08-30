# MinitestLog


With ```minitest_log```:
 
- All verdicts are automatically logged.
- Nested sections in the test code are carried forward into the log, giving structure to both.

## Verdicts

```example.rb```:
```ruby
require 'minitest_log'

class Example < Minitest::Test

  def test_example
    MinitestLog.open do |log|
      log.verdict_assert_equal?(:my_verdict_id, 'Lorem ipsum', 'Lorem ipsum')
    end
  end

end
```

```log.xml```:
```xml
<log>
  <summary verdicts='1' failures='0' errors='0'/>
  <verdict method='verdict_assert_equal?' outcome='passed' id='my_verdict_id'>
    <exp_value>Lorem ipsum</exp_value>
    <act_value>Lorem ipsum</act_value>
  </verdict>
</log>
```

## Logging



