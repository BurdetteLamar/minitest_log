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
      log.verdict_assert?(:assert_true, true)
      log.verdict_assert?(:assert_false, false)
    end
  end

end
```

[xml](https://raw.githubusercontent.com/BurdetteLamar/minitest_log/master/markdown/readme/verdicts/assert/log.xml)

## Logging



