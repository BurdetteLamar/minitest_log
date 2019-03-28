# MinitestLog


```MinitestLog``` layers structured logging onto module ```Minitest```.

```MinitestLog``` allows you to:

- Organize your test code as nested sections, so the test can "tell its story."  That same structure carries forward into the test's execution log.
- Specify verdicts that are logged in detail, whether passed or failed.

(Here, we say *verdict*, not *assertion*, to emphasize that a failure does not terminate the test.)

## Installation

```
gem install minitest_log
```

## Contents
- [Logs and Sections](#logs-and-sections)
  - [First Log](#first-log)
  - [Opening the Log](#opening-the-log)
  - [Nested Sections](#nested-sections)
  - [Text](#text)
  - [Attributes](#attributes)
  - [Timestamp](#timestamp)
  - [Duration](#duration)
  - [Rescue](#rescue)
- [Verdicts](#verdicts)

## Logs and Sections

### First Log

To begin with, here's a fairly simple test that uses ```minitest_log```

```example.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    # Open the log.
    MinitestLog.open do |log|
      log.section('Show off section functionality') do
        log.section('Name', 'The first argument becomes the section name.')
        log.section('Text', 'A String argument becomes text.')
        log.section('Nesting', 'Sections can nest.') do
          log.section('Outer', 'Outer section.') do
            log.section('Inner', 'Inner section.')
            log.section('Another','Another.')
          end
        end
        log.section('Childless', 'A section need not have children.')
        log.section('Attributes', {:a => 0, :b => 1}, 'A Hash becomes attributes.')
        log.section('Timestamp', :timestamp, 'Symbol :timestamp requests that the current time be logged.')
        log.section('Duration', :duration, 'Symbol :duration requests that the duration be logged .') do
          sleep(1)
        end
        log.section('Rescue', :rescue, 'Symbol :rescue, requests that any exception be rescued and logged.') do
          raise Exception.new('Oops!')
          log.comment('This comment will not be reached.')
        end
        log.comment('This comment will be reached.')
        log.section(
            'Pot pourri',
            :duration,
            :timestamp,
            :rescue,
            {:a => 0, :b => 1},
            'A section can have lots of stuff.'
        )
      end
      # cdata, comment, put_element, put_data
      # Use nested sections to help organize the test code.
      log.section('Test some math methods') do
        log.section('Trigonometric') do
          # Use verdicts to verify values.
          log.verdict_assert_equal?('sine of 0.0', 0.0, Math::sin(0.0))
          # Use method :va_equal? as a shorthand alias for method :verdict_assert_equal?.
          log.va_equal?('cosine of 0.0', 1.0, Math::cos(0.0))
        end
        log.section('Exponentiation') do
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
  <section_ name='Show off section functionality'>
    <section_ name='Name'>
      The first argument becomes the section name.
    </section_>
    <section_ name='Text'>
      A String argument becomes text.
    </section_>
    <section_ name='Nesting'>
      Sections can nest.
      <section_ name='Outer'>
        Outer section.
        <section_ name='Inner'>
          Inner section.
        </section_>
        <section_ name='Another'>
          Another.
        </section_>
      </section_>
    </section_>
    <section_ name='Childless'>
      A section need not have children.
    </section_>
    <section_ name='Attributes' a='0' b='1'>
      A Hash becomes attributes.
    </section_>
    <section_ name='Timestamp' timestamp='2019-03-28-Thu-12.08.30.537'>
      Symbol :timestamp requests that the current time be logged.
    </section_>
    <section_ name='Duration' duration_seconds='1.001'>
      Symbol :duration requests that the duration be logged .
    </section_>
    <section_ name='Rescue'>
      Symbol :rescue, requests that any exception be rescued and logged.
      <rescued_exception_ class='Exception' message='Oops!'>
        <backtrace_>
          <level_0_ location='example.rb:22:in `block (3 levels) in test_example&apos;'/>
          <level_1_ location='example.rb:21:in `block (2 levels) in test_example&apos;'/>
          <level_2_ location='example.rb:6:in `block in test_example&apos;'/>
          <level_3_ location='example.rb:5:in `test_example&apos;'/>
        </backtrace_>
      </rescued_exception_>
    </section_>
    <comment_>
      This comment will be reached.
    </comment_>
    <section_ name='Pot pourri' timestamp='2019-03-28-Thu-12.08.31.541' a='0' b='1' duration_seconds='0.000'>
      A section can have lots of stuff.
    </section_>
  </section_>
  <section_ name='Test some math methods'>
    <section_ name='Trigonometric'>
      <verdict_ method='verdict_assert_equal?' outcome='passed' id='sine of 0.0'>
        <expected_ class='Float' value='0.0'/>
        <actual_ class='Float' value='0.0'/>
      </verdict_>
      <verdict_ method='verdict_assert_equal?' outcome='passed' id='cosine of 0.0'>
        <expected_ class='Float' value='1.0'/>
        <actual_ class='Float' value='1.0'/>
      </verdict_>
    </section_>
    <section_ name='Exponentiation'>
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
  <section_ name='My section' timestamp='2019-03-28-Thu-12.08.33.707'/>
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


## Verdicts

TODO
