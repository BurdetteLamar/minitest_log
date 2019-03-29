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
require 'set'
require 'uri'
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('Built-in classes') do
        log.section('String') do
          string = "When you come to a fork in the road, take it. -- Yogi Berra"
          log.put_data('My string', string)
        end
        log.section('Objects logged using :each_pair') do
          hash = {
              :name => 'Ichabod Crane',
              :address => '14 Main Street',
              :city => 'Sleepy Hollow',
              :state => 'NY',
              :zipcode => '10591',
          }
          Struct.new('Foo', :x, :y, :z)
          foo = Struct::Foo.new(0, 1, 2)
          log.put_data('My hash', hash)
          log.put_data('My struct', foo)
        end
        log.section('Objects logged using :each_with_index') do
          array = %w/apple orange peach banana strawberry pear/
          set = Set.new(array)
          dir = Dir.new(File.dirname(__FILE__ ))
          log.put_data('My array', array)
          log.put_data('My set', set)
          log.put_data('My directory', dir)
        end
        log.section('Objects logged using :to_s') do
          log.put_data('My integer', 0)
          log.put_data('My exception', Exception.new('Boo!'))
          log.put_data('My regexp', 'Bar')
          log.put_data('My time', Time.now)
          log.put_data('My uri,', URI('https://www.github.com'))
        end
      end
    end
  end
end
```

```log.xml```:
```xml
<log>
  <section_ name='Built-in classes'>
    <section_ name='String'>
      <data_ name='My string' class='String' size='59'>
        When you come to a fork in the road, take it. -- Yogi Berra
      </data_>
    </section_>
    <section_ name='Objects logged using :each_pair'>
      <data_ name='My hash' class='Hash' method=':each_pair' size='5'>
        <![CDATA[
name => Ichabod Crane
address => 14 Main Street
city => Sleepy Hollow
state => NY
zipcode => 10591
]]>
      </data_>
      <data_ name='My struct' class='Struct::Foo' method=':each_pair' size='3'>
        <![CDATA[
x => 0
y => 1
z => 2
]]>
      </data_>
    </section_>
    <section_ name='Objects logged using :each_with_index'>
      <data_ name='My array' class='Array' method=':each_with_index' size='6'>
        <![CDATA[
0: apple
1: orange
2: peach
3: banana
4: strawberry
5: pear
]]>
      </data_>
      <data_ name='My set' class='Set' method=':each_with_index' size='6'>
        <![CDATA[
0: apple
1: orange
2: peach
3: banana
4: strawberry
5: pear
]]>
      </data_>
      <data_ name='My directory' class='Dir' method=':each_with_index'>
        <![CDATA[
0: .
1: ..
2: example.rb
3: log.xml
4: template.md
]]>
      </data_>
    </section_>
    <section_ name='Objects logged using :to_s'>
      <data_ name='My integer' class='Integer' method=':to_s'>
        0
      </data_>
      <data_ name='My exception' class='Exception' method=':to_s'>
        Boo!
      </data_>
      <data_ name='My regexp' class='String' size='3'>
        Bar
      </data_>
      <data_ name='My time' class='Time' method=':to_s'>
        2019-03-29 12:07:12 -0500
      </data_>
      <data_ name='My uri,' class='URI::HTTPS' method=':to_s'>
        https://www.github.com
      </data_>
    </section_>
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
  <section_ name='My section with timestamp' timestamp='2019-03-29-Fri-12.07.13.630'>
    Section with timestamp.
  </section_>
  <section_ name='My section with duration' duration_seconds='0.500'>
    Section with duration.
  </section_>
  <section_ name='My section with both' timestamp='2019-03-29-Fri-12.07.14.131' duration_seconds='0.500'>
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
