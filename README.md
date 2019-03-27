# MinitestLog

```MinitestLog``` allows you to:

- Structure your test code as nested sections.  The same structure carries forward into the test's execution log.
- Specify verdicts (verifications) that are fully logged, whether passed or failed.

(Here, we say *verdict*, not *assertion*, to emphasize that a failure does not terminate the test.)

## Contents
- [Installation](#installation)
- [Verdicts](#verdicts)
- [Logs and Sections](#logs-and-sections)
  - [First Log](#first-log)
  - [Opening the Log](#opening-the-log)
  - [Nested Sections](#nested-sections)
  - [Text](#text)
  - [Attributes](#attributes)
  - [Timestamp](#timestamp)
  - [Duration](#duration)
  - [Rescue](#rescue)

## Installation

```
gem install minitest_log
```
## Verdicts

TODO

## Logs and Sections

### First Log

To begin with, here's a fairly simple test that uses ```minitest_log```

```example.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.open do |log|
      # Use nested sections to help organize the test code.
      log.section('Test some math methods') do
        log.section('Trig') do
          # Use verdicts to verify values.
          log.verdict_assert_equal?('sine of 0.0', 0.0, Math::sin(0.0))
          # Use method :va_equal? as a shorthand alias for method :verdict_assert_equal?.
          log.va_equal?('cosine of 0.0', 1.0, Math::cos(0.0))
        end
        log.section('Log') do
          log.va_equal?('exp of 0.0', 1.0, Math::exp(0.0))
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
  <section_ name='Test some math methods'>
    <section_ name='Trig'>
      <verdict_ method='verdict_assert_equal?' outcome='passed' id='sine of 0.0'>
        <expected_ class='Float' value='0.0'/>
        <actual_ class='Float' value='0.0'/>
      </verdict_>
      <verdict_ method='verdict_assert_equal?' outcome='passed' id='cosine of 0.0'>
        <expected_ class='Float' value='1.0'/>
        <actual_ class='Float' value='1.0'/>
      </verdict_>
    </section_>
    <section_ name='Log'>
      <verdict_ method='verdict_assert_equal?' outcome='passed' id='exp of 0.0'>
        <expected_ class='Float' value='1.0'/>
        <actual_ class='Float' value='1.0'/>
      </verdict_>
    </section_>
  </section_>
</log>
```

### Opening the Log

Open a log by calling ```MinitestLog#open```.

```open.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.open do |log|
      # Test code goes here.
    end
  end
end
```

The log:

```log.xml```:
```xml
<log/>
```

### Nested Sections

Nest sections in a log by nesting calls to ```MinitestLog#section```.

The nesting gives structure to both the test and the log.

```example.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.open do |log|
      # Test code can go here.
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
  <section_ name='My section' timestamp='2019-03-27-Wed-14.05.50.428'/>
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
  <section_ name='My section'>
    <rescued_exception_ class='RuntimeError' message='Boo!'>
      <backtrace_>
        <level_0_ location='example.rb:6:in `block (2 levels) in test_example&apos;'/>
        <level_1_ location='example.rb:5:in `block in test_example&apos;'/>
        <level_2_ location='example.rb:4:in `test_example&apos;'/>
      </backtrace_>
    </rescued_exception_>
  </section_>
</log>
```




