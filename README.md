# MinitestLog


```MinitestLog``` gives you three things:

- **Nested sections:**  Use nested sections to structure your test (and its log), so that it can "tell its story" clearly.
- **Data explication:**  Use data-logging methods to log objects. Most collections (```Aray```, ```Hash```, etc.) are explicated piece-by-piece.
- **Verdicts:** Use verdict methods to express assertions. Each verdict method calls a corresponding assertion method (in ```Minitest::Assertions```).  Details for the verdict are logged, whether passed or failed.

## Installation

```
gem install minitest_log
```

## Contents
- [Logs and Sections](#logs-and-sections)
  - [Nested Sections](#nested-sections)
  - [Attributes](#attributes)
  - [About Time](#about-time)
  - [Rescue](#rescue)
- [Data](#data)
  - [Strings](#strings)
  - [Hash-Like Objects](#hash-like-objects)
  - [Array-Like Objects](#array-like-objects)
  - [Other Objects](#other-objects)
- [Verdicts](#verdicts)
  - [Assert Verdicts](#assert-verdicts)
    - [<code>verdict_assert?</code>](#-code-verdict_assert-code-)
    - [<code>verdict_assert_empty?</code>](#-code-verdict_assert_empty-code-)
  - [Refute Verdicts](#refute-verdicts)

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

### Attributes

Put attributes onto a section by calling ```section``` with hash arguments.

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

Use symbols ```:timestamp``` or ```:duration``` to add a timestamp or a duration to a section.

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
  <section_ name='My section with timestamp' timestamp='2019-04-01-Mon-13.59.30.190'>
    Section with timestamp.
  </section_>
  <section_ name='My section with duration' duration_seconds='0.500'>
    Section with duration.
  </section_>
  <section_ name='My section with both' timestamp='2019-04-01-Mon-13.59.30.691' duration_seconds='0.500'>
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


## Data

Put data onto the log using method ```:put_data```.

Generally speaking, a collection will be explicated in the log.

### Strings

An object that is a ```kind_of?(String)``` is logged simply.

```kind_of_string.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('kind_of_string.xml') do |log|
      log.section('Objects that are a kind_of?(String)') do
        string = 'When you come to a fork in the road, take it. -- Yogi Berra'
        log.put_data('My string', string)
      end
    end
  end
end
```

```kind_of_string.xml```:
```xml
<log>
  <section_ name='Objects that are a kind_of?(String)'>
    <data_ name='My string' class='String' size='59'>
      When you come to a fork in the road, take it. -- Yogi Berra
    </data_>
  </section_>
</log>
```

### Hash-Like Objects

Otherwise, an object that ```respond_to?(:each_with_pair)``` is logged as name-value pairs.

```each_pair.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('each_pair.xml') do |log|
      log.section('Objects logged using :each_pair') do
        log.section('Hash') do
          hash = {
              :name => 'Ichabod Crane',
              :address => '14 Main Street',
              :city => 'Sleepy Hollow',
              :state => 'NY',
              :zipcode => '10591',
          }
          log.put_data('My hash', hash)
        end
        log.section('Struct') do
          Struct.new('Foo', :x, :y, :z)
          foo = Struct::Foo.new(0, 1, 2)
          log.put_data('My struct', foo)
        end
      end
    end
  end
end
```

```each_pair.xml```:
```xml
<log>
  <section_ name='Objects logged using :each_pair'>
    <section_ name='Hash'>
      <data_ name='My hash' class='Hash' method=':each_pair' size='5'>
        <![CDATA[
name => Ichabod Crane
address => 14 Main Street
city => Sleepy Hollow
state => NY
zipcode => 10591
]]>
      </data_>
    </section_>
    <section_ name='Struct'>
      <data_ name='My struct' class='Struct::Foo' method=':each_pair' size='3'>
        <![CDATA[
x => 0
y => 1
z => 2
]]>
      </data_>
    </section_>
  </section_>
</log>
```

### Array-Like Objects

Otherwise, an object that ```respond_to?(:each_with_index)``` is logged as a numbered list.

```each_with_index.rb```:
```ruby
require 'set'
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('each_with_index.xml') do |log|
      log.section('Objects logged using :each_with_index') do
        log.section('Array') do
          array = %w/apple orange peach banana strawberry pear/
          log.put_data('My array', array)
        end
        log.section('Set') do
          set = Set.new(%w/baseball football basketball hockey/)
          puts set.respond_to?(:each_with_index)
          log.put_data('My set', set)
        end
      end
    end
  end
end
```

```each_with_index.xml```:
```xml
<log>
  <section_ name='Objects logged using :each_with_index'>
    <section_ name='Array'>
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
    </section_>
    <section_ name='Set'>
      <data_ name='My set' class='Set' method=':each_with_index' size='4'>
        <![CDATA[
0: baseball
1: football
2: basketball
3: hockey
]]>
      </data_>
    </section_>
  </section_>
</log>
```

### Other Objects

Otherwise, the logger tries, successively, to log the object using ```:to_s```,
```:inspect```, and ```:__id__```.

If all that fails, the logger raises an exception (which is not illustrated here).

```to_s.rb```:
```ruby
require 'uri'
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('to_s.xml') do |log|
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
```

```to_s.xml```:
```xml
<log>
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
      2019-04-01 13:59:28 -0500
    </data_>
    <data_ name='My uri,' class='URI::HTTPS' method=':to_s'>
      https://www.github.com
    </data_>
  </section_>
</log>
```


## Verdicts

Use ```MinitestLog``` verdicts to log details of ```Minitest``` assertions.

Each verdict method in ```MinitestLog``` is a wrapper for a corresponding ```Minitest``` assertion (or refutation).

The wrapping verdict logs all details for the wrapped assertion.

The arguments for the verdict method and its assert method are the same, except that the verdict method adds a required leading verdict identifier.  (Both allow an optional trailing message string.)

The verdict identifier:
- Is commonly a string or a symbol, but may be any object that responds to ```:to_s```.
- Must be unique among the verdict identifiers in its *test method* (but not necessarily in its *test class*.)

Example verdict:

```ruby
log.verdict_assert?(:my_verdict_id, true, 'My message')
```

Each verdict method returns ```true``` or ```false``` to indicate whether the verdict succeeded or failed.

### Assert Verdicts

#### <code>verdict_assert?</code>

```verdict_assert.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_verdict_assert
    MinitestLog.new('verdict_assert.xml') do |log|
      log.verdict_assert?(:true_id, true, 'True message')
      log.verdict_assert?(:false_id, false, 'False message')
    end
  end
end
```

```verdict_assert.xml```:
```xml
<log>
  <verdict_ method='verdict_assert?' outcome='passed' id='true_id' message='True message'>
    <actual_ class='TrueClass' value='true'/>
  </verdict_>
  <verdict_ method='verdict_assert?' outcome='failed' id='false_id' message='False message'>
    <actual_ class='FalseClass' value='false'/>
    <exception_ class='Minitest::Assertion' message='Expected false to be truthy.'>
      <backtrace_>
        <level_0_ location='verdict_assert.rb:6:in `block in test_verdict_assert&apos;'/>
        <level_1_ location='verdict_assert.rb:4:in `new&apos;'/>
        <level_2_ location='verdict_assert.rb:4:in `test_verdict_assert&apos;'/>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### <code>verdict_assert_empty?</code>

```verdict_assert_empty.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_verdict_assert
    MinitestLog.new('verdict_assert_empty.xml') do |log|
      log.verdict_assert_empty?(:empty_id, true, 'Empty message')
      log.verdict_assert_empty?(:not_empty_id, false, 'Not empty message')
    end
  end
end
```

```verdict_assert_empty.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_empty?' outcome='failed' id='empty_id' message='Empty message'>
    <actual_ class='TrueClass' value='true'/>
    <exception_ class='Minitest::Assertion' message='Expected true (TrueClass) to respond to #empty?.'>
      <backtrace_>
        <level_0_ location='verdict_assert_empty.rb:5:in `block in test_verdict_assert&apos;'/>
        <level_1_ location='verdict_assert_empty.rb:4:in `new&apos;'/>
        <level_2_ location='verdict_assert_empty.rb:4:in `test_verdict_assert&apos;'/>
      </backtrace_>
    </exception_>
  </verdict_>
  <verdict_ method='verdict_assert_empty?' outcome='failed' id='not_empty_id' message='Not empty message'>
    <actual_ class='FalseClass' value='false'/>
    <exception_ class='Minitest::Assertion' message='Expected false (FalseClass) to respond to #empty?.'>
      <backtrace_>
        <level_0_ location='verdict_assert_empty.rb:6:in `block in test_verdict_assert&apos;'/>
        <level_1_ location='verdict_assert_empty.rb:4:in `new&apos;'/>
        <level_2_ location='verdict_assert_empty.rb:4:in `test_verdict_assert&apos;'/>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```


### Refute Verdicts


