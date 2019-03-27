# MinitestLog

Class ```MinitestLog``` is a wrapper for class ```Minitest::Assertions``` that:

- Automatically and fully logs each assertion, whether passing or failing.
- Allows a test to be structured as nested sections.

Here, we say *verdict*, not *assertion*, to emphasize that a failure does not terminate the test.

## Contents
- [Verdicts](#verdicts)
- [Logs and Sections](#logs-and-sections)
  - [Opening the Log](#opening-the-log)
  - [Nested Sections](#nested-sections)
  - [Text](#text)
  - [Attributes](#attributes)
  - [Timestamp](#timestamp)
  - [Duration](#duration)
  - [Rescue](#rescue)

So, we have:
 
- **Verdicts**:
  - All verdicts are automatically logged.
  - Verdicts for certain collections are closely analyzed (e.g., ```Hash```, ```Sets```).
- **Sections** that can have:
  - Nested subsections
  - Verdicts
  - Text
  - Attributes
  - Duration
  - Timestamp
  - Rescuing
  - Comments

## Verdicts

TODO

## Logs and Sections

### Opening the Log

Open a log by calling ```MinitestLog#open```.

```open.rb```:
```ruby
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open do |log|
      log.comment('Test stuff goes here.')
    end
  end

end
```

The log:

```log.xml```:
```xml
<log>
  <summary_ verdicts='0' failures='0' errors='0'/>
  <comment_>
    Test stuff goes here.
  </comment_>
</log>
```

Customize a log by calling ```MinitestLog#open``` with options.

```options.rb```:
```ruby
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    options = {
        :root_name => 'my_root_name',
        :xml_indentation => 4,
    }
    MinitestLog.open('my_log.xml', options) do |log|
      log.comment('Test code goes here.')
    end
  end

end
```

The log:

```my_log.xml```:
```xml
<my_root_name>
    <summary_ verdicts='0' failures='0' errors='0'/>
    <comment_>
        Test code goes here.
    </comment_>
</my_root_name>
```


### Nested Sections

Nest sections in a log by nesting calls to ```MinitestLog#section```.

The nesting gives structure to both the test and the log.

```nested_sections.rb```:
```ruby
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open do |log|
      log.section('First outer') do
        log.section('First inner') do
        end
        log.section('Second inner') do
        end
      end
      log.section('Second outer') do
        log.section('First inner') do
        end
        log.section('Second inner') do
        end
      end
    end
  end

end
```

The log:

```log.xml```:
```xml
<log>
  <summary_ verdicts='0' failures='0' errors='0'/>
  <section_ name='First outer'>
    <section_ name='First inner'/>
    <section_ name='Second inner'/>
  </section_>
  <section_ name='Second outer'>
    <section_ name='First inner'/>
    <section_ name='Second inner'/>
  </section_>
</log>
```

### Text

Put text onto a section by calling ```MinitestLog#section``` with string arguments.

Each string becomes part of the section's text.

The section name is always the first argument, but otherwise strings can be anywhere among the arguments.

```example.rb```:
```ruby
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open do |log|
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
  <summary_ verdicts='0' failures='0' errors='0'/>
  <section_ name='My section'>
    Text
  </section_>
  <section_ name='Another section'>
    Text and more text
  </section_>
</log>
```

### Attributes

Put attributes onto a section by calling ```MinitestLog#section``` with hash arguments.

Each name/value pair in the hash becomes an attribute in the log section header.

The section name is always the first argument, but otherwise hashes can be anywhere among the arguments.

```example.rb```:
```ruby
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open do |log|
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
  <summary_ verdicts='0' failures='0' errors='0'/>
  <section_ name='My section' first_attr='first' second_attr='second'/>
  <section_ name='Another section' first_attr='first' second_attr='second' third_attr='third'/>
</log>
```

### Timestamp
 
 Put a timestamp onto a section by calling ```MinitestLog#section``` with the symbol ```:timestamp```.
 
 The section name is always the first argument, but otherwise the symbol can be anywhere among the arguments.
 
```example.rb```:
```ruby
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open do |log|
      log.section('My section', :timestamp) do
      end
    end
  end

end
```

The log:

```log.xml```:
```xml
<log>
  <summary_ verdicts='0' failures='0' errors='0'/>
  <section_ name='My section' timestamp='2019-03-27-Wed-10.35.24.469'/>
</log>
```

### Duration

Put a duration onto a section by calling ```MinitestLog#section``` with the symbol ```:duration```.  The log will then include the execution duration for the section.

The section name is always the first argument, but otherwise the symbol can be anywhere among the arguments.

```example.rb```:
```ruby
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open do |log|
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
  <summary_ verdicts='0' failures='0' errors='0'/>
  <section_ name='My section' duration_seconds='3.000'/>
</log>
```

### Rescue

Specify rescuing for a section by calling ```MinitestLog#section``` with the symbol ```:rescue```.

Any exception raised during the section's execution will be rescued and logged.  Such an exception terminates the *section*, but not the *test*.

(An unrescued exception does terminate the test.)

```example.rb```:
```ruby
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open do |log|
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
  <summary_ verdicts='0' failures='0' errors='1'/>
  <section_ name='My section'>
    <rescued_exception_ class='RuntimeError' message='Boo!'>
      <backtrace_>
        <level_0_ location='example.rb:8:in `block (2 levels) in test_example&apos;'/>
        <level_1_ location='example.rb:7:in `block in test_example&apos;'/>
        <level_2_ location='example.rb:6:in `test_example&apos;'/>
      </backtrace_>
    </rescued_exception_>
  </section_>
</log>
```




