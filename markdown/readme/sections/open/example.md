## Open a Log

This example shows how to open a log.

```open.rb```:
```ruby
require 'minitest/autorun'
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open(self) do |log|
      # Test stuff goes here.
    end
  end

end
```

The log:

```log.xml```:
```xml
<log>
  <summary verdicts='0' failures='0' errors='0'/>
</log>
```

This example shows how to use options in opening a log.

```options.rb```:
```ruby
require 'minitest/autorun'
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    options = {
        :file_path => 'my_log.xml',
        :root_name => 'my_root_name',
        :xml_indentation => 4,
    }
    MinitestLog.open(self, options) do |log|
      # Test stuff goes here.
    end
  end

end
```

The log:

```my_log.xml```:
```xml
<my_root_name>
    <summary verdicts='0' failures='0' errors='0'/>
</my_root_name>
```

