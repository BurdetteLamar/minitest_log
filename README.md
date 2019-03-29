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
  - [Nested Sections](#nested-sections)
  - [Data](#data)
  - [Attributes](#attributes)
  - [About Time](#about-time)
  - [Rescue](#rescue)
- [Verdicts](#verdicts)

## Logs and Sections

### Nested Sections

Give structure to your log by nesting sections.

The first argument is always the section name.  Additional string arguments become text (PCDATA).

```example.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('My section name', 'The first argument becomes the section name.')
      log.section('Another section name', 'After the section name, any string argument becomes text.')
      log.section('My nested sections', 'Sections can nest.') do
        log.section('Outer', 'Outer section.') do
          log.section('Inner', 'Inner section.')
          log.section('Another','Another.')
        end
      end
    end
  end
end
```

```log.xml```:
```xml
<log>
  <section_ name='My section name'>
    The first argument becomes the section name.
  </section_>
  <section_ name='Another section name'>
    After the section name, any string argument becomes text.
  </section_>
  <section_ name='My nested sections'>
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
</log>
```

### Data

You can put data into a section.

Generally speaking, a collection will be explicated in the log.

```example.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('My data section') do
        string = "When you come to a fork in the road, take it. -- Yogi Berra"
        hash = {
            :name => 'Ichabod Crane',
            :address => '14 Main Street',
            :city => 'Sleepy Hollow',
            :state => 'NY',
            :zipcode => '10591',
        }
        array = %w/apple orange peach banana strawberry pear/
        log.put_data('My string', string)
        log.put_data('My hash', hash)
        log.put_data('My array', array)
      end
    end
  end
end
```

```log.xml```:
```xml
<log>
  <section_ name='My data section'>
    <data_ name='My string' class='String' size='59'>
      When you come to a fork in the road, take it. -- Yogi Berra
    </data_>
    <data_ name='My hash' class='Hash' size='5' method=':each_pair'>
      <![CDATA[
name => Ichabod Crane
address => 14 Main Street
city => Sleepy Hollow
state => NY
zipcode => 10591
]]>
    </data_>
    <data_ name='My array' class='Array' size='6' method=':each_with_index'>
      <![CDATA[
0: apple
1: orange
2: peach
3: banana
4: strawberry
5: pear
]]>
    </data_>
  </section_>
</log>
```

### Attributes

You can put attributes onto a section by calling ```section``` with hash arguments.

Each name/value pair in the hash becomes an attribute in the log section header.

The first argument is always the section name.  Addition hash arguments become attributes.

```example.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      attrs = {:first_attr => 'first', :second_attr => 'second'}
      log.section('My section with attributes', attrs, 'A Hash becomes attributes.')
      more_attrs = {:third_attr => 'third'}
      log.section('My section with more attributes', attrs, more_attrs, 'More attributes.')
    end
  end
end
```

```log.xml```:
```xml
<log>
  <section_ name='My section with attributes' first_attr='first' second_attr='second'>
    A Hash becomes attributes.
  </section_>
  <section_ name='My section with more attributes' first_attr='first' second_attr='second' third_attr='third'>
    More attributes.
  </section_>
</log>
```

### About Time

Use symbols ```:timestamp``` or ```:duration``` to add a timestamp and a duration to as section.

```example.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('My section with timestamp', :timestamp, 'Section with timestamp.')
      log.section('My section with duration', :duration, 'Section with duration.') do
        sleep(0.5)
      end
      log.section('My section with both', :duration, :timestamp, 'Section with both.') do
        sleep(0.5)
      end
    end
  end
end
```

```log.xml```:
```xml
<log>
  <section_ name='My section with timestamp' timestamp='2019-03-29-Fri-10.31.19.025'>
    Section with timestamp.
  </section_>
  <section_ name='My section with duration' duration_seconds='0.500'>
    Section with duration.
  </section_>
  <section_ name='My section with both' timestamp='2019-03-29-Fri-10.31.19.526' duration_seconds='0.501'>
    Section with both.
  </section_>
</log>
```

### Rescue

Rescue a section using the symbol ```:rescue```.

Any exception raised during that section's execution will be rescued and logged.  Such an exception terminates the *section* (but not the *test*).

```example.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('My rescued section', :rescue) do
        raise RuntimeError.new('Boo!')
      end
    end
  end
end
```

```log.xml```:
```xml
<log>
  <section_ name='My rescued section'>
    <rescued_exception_ class='RuntimeError' message='Boo!'>
      <backtrace_>
        <level_0_ location='example.rb:6:in `block (2 levels) in test_example&apos;'/>
        <level_1_ location='example.rb:5:in `block in test_example&apos;'/>
        <level_2_ location='example.rb:4:in `new&apos;'/>
        <level_3_ location='example.rb:4:in `test_example&apos;'/>
      </backtrace_>
    </rescued_exception_>
  </section_>
</log>
```


## Verdicts

TODO
