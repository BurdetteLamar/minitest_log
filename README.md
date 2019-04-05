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
  - [Unrescued Exception](#unrescued-exception)
- [Data](#data)
  - [Strings](#strings)
  - [Hash-Like Objects](#hash-like-objects)
  - [Array-Like Objects](#array-like-objects)
  - [Other Objects](#other-objects)
- [Verdicts](#verdicts)
  - [Assert Verdicts](#assert-verdicts)
    - [verdict_assert?](#verdict_assert)
    - [verdict_assert_empty?](#verdict_assert_empty)
    - [verdict_assert_equal?](#verdict_assert_equal)
    - [verdict_assert_in_delta?](#verdict_assert_in_delta)
    - [verdict_assert_in_epsilon?](#verdict_assert_in_epsilon)
    - [verdict_assert_includes?](#verdict_assert_includes)
    - [verdict_assert_instance_of?](#verdict_assert_instance_of)
    - [verdict_assert_kind_of?](#verdict_assert_kind_of)
    - [verdict_assert_match?](#verdict_assert_match)
    - [verdict_assert_nil?](#verdict_assert_nil)
    - [verdict_assert_operator?](#verdict_assert_operator)
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
  <section_ name='My section with timestamp' timestamp='2019-04-05-Fri-14.43.27.632'>
    Section with timestamp.
  </section_>
  <section_ name='My section with duration' duration_seconds='0.500'>
    Section with duration.
  </section_>
  <section_ name='My section with both' timestamp='2019-04-05-Fri-14.43.28.133' duration_seconds='0.500'>
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
        log.comment('This code will not be reached, because the section terminates.')
      end
      log.comment('This code will be reached, because it is not in the terminated section.')
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
  <comment_>
    This code will be reached, because it is not in the terminated section.
  </comment_>
</log>
```

### Unrescued Exception

An exception raised in an unrescued section is logged, and the test terminates.

```example.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('My unrescued section') do
        raise RuntimeError.new('Boo!')
      end
      log.comment('This code will not be reached, because the test terminated.')
    end
  end
end
```

```log.xml```:
```xml
<log>
  <section_ name='My unrescued section'>
    <uncaught_exception_ timestamp='2019-04-05-Fri-14.43.29.069' class='RuntimeError'>
      <message_>
        Boo!
      </message_>
      <backtrace_>
        <![CDATA[example.rb:6:in `block (2 levels) in test_example'
example.rb:5:in `block in test_example'
example.rb:4:in `new'
example.rb:4:in `test_example']]>
      </backtrace_>
    </uncaught_exception_>
  </section_>
</log>
```

## Data

Put data onto the log using method ```:put_data```.

A data object ```obj``` is treated as follows:

- If ```obj.kind_of?(String)```, it is treated as a [string](#strings)
- Otherwise if ```obj.respond_to?(:each_pair)```, it is treated as [hash-like](#hash-like-objects).
- Otherwise, it ```obj.respond_to?(:each_with_index```, it is treated as [array-like](#array-like-objects).
- Otherwise, it is treated as "[other](#other-objects)".

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

Otherwise, an object that ```respond_to?(:each_pair)``` is logged as name-value pairs.

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
      2019-04-05 14:43:25 -0500
    </data_>
    <data_ name='My uri,' class='URI::HTTPS' method=':to_s'>
      https://www.github.com
    </data_>
  </section_>
</log>
```


## Verdicts

Use ```MinitestLog``` verdict methods to log details of ```Minitest``` assertions.

Each verdict method in ```MinitestLog``` is a wrapper for a corresponding ```Minitest``` assertion (or refutation).

The verdict method logs all details for the assertion.

The arguments for the verdict method and its assert method are the same, except that the verdict method adds a required leading verdict identifier.  (Both allow an optional trailing message string.)

The verdict identifier:
- Is commonly a string or a symbol, but may be any object that responds to ```:to_s```.
- Must be unique among the verdict identifiers in its *test method* (but not necessarily in its *test class*.)

Each verdict method returns ```true``` or ```false``` to indicate whether the verdict succeeded or failed.

Each verdict method also has a shorter alias -- ```va``` substituting for ```verdict_assert```, and ```vr``` substituting for ```verdict_refute```.  (This not only saves keystrokes, but also *really*, *really* helps your editor do code completion.)

Example verdict (long form and alias):

```ruby
log.verdict_assert?(:my_verdict_id, true, 'My message')
log.va?(:my_verdict_id, true, 'My message')
```

Verdict methods are described below.  For each, the following is given:

- The method's syntax.
- An example test using the method, including both passing and failing verdicts.
- The log output by the example test.
- Descriptive text, adapted from [docs.ruby-lang.org](https://docs.ruby-lang.org/en/2.1.0/MiniTest/Assertions.html)

### Assert Verdicts

#### verdict_assert?

```ruby
verdict_assert?(id, obj, msg = nil)
va?(id, obj, msg = nil)
```

Fails unless ```obj``` is truthy.

```verdict_assert.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert.xml') do |log|
      log.verdict_assert?(:one_id, true, 'One message')
      log.verdict_assert?(:another_id, false, 'Another message')
    end
  end
end
```

```verdict_assert.xml```:
```xml
<log>
  <verdict_ method='verdict_assert?' outcome='passed' id='one_id' message='One message'>
    <actual_ class='TrueClass' value='true'/>
  </verdict_>
  <verdict_ method='verdict_assert?' outcome='failed' id='another_id' message='Another message'>
    <actual_ class='FalseClass' value='false'/>
    <exception_ class='Minitest::Assertion' message='Expected false to be truthy.'>
      <backtrace_>
        <level_0_ location='verdict_assert.rb:6:in `block in test_demo_verdict&apos;'/>
        <level_1_ location='verdict_assert.rb:4:in `new&apos;'/>
        <level_2_ location='verdict_assert.rb:4:in `test_demo_verdict&apos;'/>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_empty?

```ruby
verdict_assert_empty?(id, obj, msg = nil)
va_empty?(id, obj, msg = nil)
```

Fails unless ```obj``` is empty.

```verdict_assert_empty.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_empty.xml') do |log|
      log.verdict_assert_empty?(:one_id, [], 'One message')
      log.verdict_assert_empty?(:another_id, [:a], 'Another message')
    end
  end
end
```

```verdict_assert_empty.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_empty?' outcome='passed' id='one_id' message='One message'>
    <actual_ class='Array' value='[]'/>
  </verdict_>
  <verdict_ method='verdict_assert_empty?' outcome='failed' id='another_id' message='Another message'>
    <actual_ class='Array' value='[:a]'/>
    <exception_ class='Minitest::Assertion' message='Expected [:a] to be empty.'>
      <backtrace_>
        <level_0_ location='verdict_assert_empty.rb:6:in `block in test_demo_verdict&apos;'/>
        <level_1_ location='verdict_assert_empty.rb:4:in `new&apos;'/>
        <level_2_ location='verdict_assert_empty.rb:4:in `test_demo_verdict&apos;'/>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_equal?

```ruby
verdict_assert_equal?(id, exp, act, msg = nil)
va_equal?(id, exp, act, msg = nil)
```
Fails unless ```exp == act```.

For floats use verdict_assert_in_delta?.

```verdict_assert_equal.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_equal.xml') do |log|
      log.verdict_assert_equal?(:one_id, 0, 0, 'One message')
      log.verdict_assert_equal?(:another_id, 0, 1, 'Another message')
    end
  end
end
```

```verdict_assert_equal.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_equal?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Integer' value='0'/>
    <actual_ class='Integer' value='0'/>
  </verdict_>
  <verdict_ method='verdict_assert_equal?' outcome='failed' id='another_id' message='Another message'>
    <expected_ class='Integer' value='0'/>
    <actual_ class='Integer' value='1'/>
    <exception_ class='Minitest::Assertion' message='Expected: 0'>
      <backtrace_>
        <level_0_ location='verdict_assert_equal.rb:6:in `block in test_demo_verdict&apos;'/>
        <level_1_ location='verdict_assert_equal.rb:4:in `new&apos;'/>
        <level_2_ location='verdict_assert_equal.rb:4:in `test_demo_verdict&apos;'/>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_in_delta?

```ruby
verdict_assert_in_delta?(id, exp, act, delta = 0.001, msg = nil)
va_in_delta?(id, exp, act, delta = 0.001, msg = nil)
````

For comparing Floats. Fails unless ```exp``` and ```act``` are within ```delta``` of each other.

```verdict_assert_in_delta.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_in_delta.xml') do |log|
      log.verdict_assert_in_delta?(:one_id, 0, 0, 1, 'One message')
      log.verdict_assert_in_delta?(:another_id, 0, 1, 2, 'Another message')
    end
  end
end
```

```verdict_assert_in_delta.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_in_delta?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Integer' value='0'/>
    <actual_ class='Integer' value='0'/>
    <delta_ class='Integer' value='1'/>
  </verdict_>
  <verdict_ method='verdict_assert_in_delta?' outcome='passed' id='another_id' message='Another message'>
    <expected_ class='Integer' value='0'/>
    <actual_ class='Integer' value='1'/>
    <delta_ class='Integer' value='2'/>
  </verdict_>
</log>
```

#### verdict_assert_in_epsilon?

```ruby
verdict_assert_in_epsilon?(id, a, b, epsilon = 0.001, msg = nil)
va_in_epsilon?(id, a, b, epsilon = 0.001, msg = nil)
```

For comparing Floats. Fails unless ```exp``` and ```act``` have a relative error less than ```epsilon```.

```verdict_assert_in_epsilon.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verrdict
    MinitestLog.new('verdict_assert_in_epsilon.xml') do |log|
      log.verdict_assert_in_epsilon?(:one_id, 3, 2, 1, 'One message')
      log.verdict_assert_in_epsilon?(:another_id, 3, 2, 0, 'Another message')
    end
  end
end
```

```verdict_assert_in_epsilon.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_in_epsilon?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Integer' value='3'/>
    <actual_ class='Integer' value='2'/>
    <epsilon_ class='Integer' value='1'/>
  </verdict_>
  <verdict_ method='verdict_assert_in_epsilon?' outcome='failed' id='another_id' message='Another message'>
    <expected_ class='Integer' value='3'/>
    <actual_ class='Integer' value='2'/>
    <epsilon_ class='Integer' value='0'/>
    <exception_ class='Minitest::Assertion' message='Expected |3 - 2| (1) to be &lt;= 0.'>
      <backtrace_>
        <level_0_ location='verdict_assert_in_epsilon.rb:6:in `block in test_demo_verrdict&apos;'/>
        <level_1_ location='verdict_assert_in_epsilon.rb:4:in `new&apos;'/>
        <level_2_ location='verdict_assert_in_epsilon.rb:4:in `test_demo_verrdict&apos;'/>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_includes?

```ruby
verdict_assert_includes?(id, collection, obj, msg = nil)
va_includes?(id, collection, obj, msg = nil)
```

Fails unless ```collection``` includes ```obj```.

```verdict_assert_includes.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_includes.xml') do |log|
      log.verdict_assert_includes?(:one_id, [:a, :b, :c], :b, 'One message')
      log.verdict_assert_includes?(:another_id, [:a, :b, :c], :d, 'Another message')
    end
  end
end
```

```verdict_assert_includes.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_includes?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Array' value='[:a, :b, :c]'/>
    <actual_ class='Symbol' value=':b'/>
  </verdict_>
  <verdict_ method='verdict_assert_includes?' outcome='failed' id='another_id' message='Another message'>
    <expected_ class='Array' value='[:a, :b, :c]'/>
    <actual_ class='Symbol' value=':d'/>
    <exception_ class='Minitest::Assertion' message='Expected [:a, :b, :c] to include :d.'>
      <backtrace_>
        <level_0_ location='verdict_assert_includes.rb:6:in `block in test_demo_verdict&apos;'/>
        <level_1_ location='verdict_assert_includes.rb:4:in `new&apos;'/>
        <level_2_ location='verdict_assert_includes.rb:4:in `test_demo_verdict&apos;'/>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_instance_of?

```ruby
verdict_assert_instance_of?(id, cls, obj, msg = nil)
va_instance_of?(id, cls, obj, msg = nil)
```

Fails unless ```obj``` is an instance of ```cls```.

```verdict_assert_instance_of.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_instance_of.xml') do |log|
      log.verdict_assert_instance_of?(:one_id, String, 'my_string', 'One message')
      log.verdict_assert_instance_of?(:another_id, Integer, 'my_string', 'another message')
    end
  end
end
```

```verdict_assert_instance_of.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_instance_of?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Class' value='String'/>
    <actual_ class='String' value='&quot;my_string&quot;'/>
  </verdict_>
  <verdict_ method='verdict_assert_instance_of?' outcome='failed' id='another_id' message='another message'>
    <expected_ class='Class' value='Integer'/>
    <actual_ class='String' value='&quot;my_string&quot;'/>
    <exception_ class='Minitest::Assertion' message='Expected # encoding: UTF-8'>
      <backtrace_>
        <level_0_ location='verdict_assert_instance_of.rb:6:in `block in test_demo_verdict&apos;'/>
        <level_1_ location='verdict_assert_instance_of.rb:4:in `new&apos;'/>
        <level_2_ location='verdict_assert_instance_of.rb:4:in `test_demo_verdict&apos;'/>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_kind_of?

```ruby
verdict_assert_kind_of?(id, cls, obj, msg = nil)
va_kind_of?(id, cls, obj, msg = nil)
```

Fails unless ```obj``` is a kind of ```cls```.

```verdict_assert_kind_of.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_kind_of.xml') do |log|
      log.verdict_assert_kind_of?(:one_id, Numeric, 1.0, 'One message')
      log.verdict_assert_kind_of?(:another_id, String, 1.0, 'Another message')
    end
  end
end
```

```verdict_assert_kind_of.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_kind_of?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Class' value='Numeric'/>
    <actual_ class='Float' value='1.0'/>
  </verdict_>
  <verdict_ method='verdict_assert_kind_of?' outcome='failed' id='another_id' message='Another message'>
    <expected_ class='Class' value='String'/>
    <actual_ class='Float' value='1.0'/>
    <exception_ class='Minitest::Assertion' message='Expected 1.0 to be a kind of String, not Float.'>
      <backtrace_>
        <level_0_ location='verdict_assert_kind_of.rb:6:in `block in test_demo_verdict&apos;'/>
        <level_1_ location='verdict_assert_kind_of.rb:4:in `new&apos;'/>
        <level_2_ location='verdict_assert_kind_of.rb:4:in `test_demo_verdict&apos;'/>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_match?

```ruby
verdict_assert_match?(id, cls, obj, msg = nil)
va_match?(id, cls, obj, msg = nil)
```

Fails unless ```matcher =~ obj```.

```verdict_assert_match.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_match.xml') do |log|
      log.verdict_assert_match?(:one_id, /foo/, 'food', 'One message')
      log.verdict_assert_match?(:another_id, /foo/, 'feed', 'Another message')
    end
  end
end
```

```verdict_assert_match.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_match?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Regexp' value='/foo/'/>
    <actual_ class='String' value='&quot;food&quot;'/>
  </verdict_>
  <verdict_ method='verdict_assert_match?' outcome='failed' id='another_id' message='Another message'>
    <expected_ class='Regexp' value='/foo/'/>
    <actual_ class='String' value='&quot;feed&quot;'/>
    <exception_ class='Minitest::Assertion' message='Expected /foo/ to match # encoding: UTF-8'>
      <backtrace_>
        <level_0_ location='verdict_assert_match.rb:6:in `block in test_demo_verdict&apos;'/>
        <level_1_ location='verdict_assert_match.rb:4:in `new&apos;'/>
        <level_2_ location='verdict_assert_match.rb:4:in `test_demo_verdict&apos;'/>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_nil?

```ruby
verdict_assert_nil?(id, obj, msg = nil)
va_nil?(id, obj, msg = nil)
```

Fails unless ```obj``` is nil.

```verdict_assert_nil.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_nil.xml') do |log|
      log.verdict_assert_nil?(:one_id, [], 'One message')
      log.verdict_assert_nil?(:another_id, [:a], 'Another message')
    end
  end
end
```

```verdict_assert_nil.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_nil?' outcome='failed' id='one_id' message='One message'>
    <actual_ class='Array' value='[]'/>
    <exception_ class='Minitest::Assertion' message='Expected [] to be nil.'>
      <backtrace_>
        <level_0_ location='verdict_assert_nil.rb:5:in `block in test_demo_verdict&apos;'/>
        <level_1_ location='verdict_assert_nil.rb:4:in `new&apos;'/>
        <level_2_ location='verdict_assert_nil.rb:4:in `test_demo_verdict&apos;'/>
      </backtrace_>
    </exception_>
  </verdict_>
  <verdict_ method='verdict_assert_nil?' outcome='failed' id='another_id' message='Another message'>
    <actual_ class='Array' value='[:a]'/>
    <exception_ class='Minitest::Assertion' message='Expected [:a] to be nil.'>
      <backtrace_>
        <level_0_ location='verdict_assert_nil.rb:6:in `block in test_demo_verdict&apos;'/>
        <level_1_ location='verdict_assert_nil.rb:4:in `new&apos;'/>
        <level_2_ location='verdict_assert_nil.rb:4:in `test_demo_verdict&apos;'/>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_operator?

```ruby
verdict_assert_operator?(id, o1, op, o2 = UNDEFINED, msg = nil)
va_operator?(id, o1, op, o2 = UNDEFINED, msg = nil)
````

For testing with binary operators.

```verdict_assert_operator.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_operator.xml') do |log|
      log.verdict_assert_operator?(:one_id, 3, :<=, 4, 'One message')
      log.verdict_assert_operator?(:another_id, 5, :<=, 4, 'Another message')
    end
  end
end
```

```verdict_assert_operator.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_operator?' outcome='passed' id='one_id' message='One message'>
    <object_1_ class='Integer' value='3'/>
    <operator_ class='Symbol' value=':&lt;='/>
    <object_2_ class='Integer' value='4'/>
  </verdict_>
  <verdict_ method='verdict_assert_operator?' outcome='failed' id='another_id' message='Another message'>
    <object_1_ class='Integer' value='5'/>
    <operator_ class='Symbol' value=':&lt;='/>
    <object_2_ class='Integer' value='4'/>
    <exception_ class='Minitest::Assertion' message='Expected 5 to be &lt;= 4.'>
      <backtrace_>
        <level_0_ location='verdict_assert_operator.rb:6:in `block in test_demo_verdict&apos;'/>
        <level_1_ location='verdict_assert_operator.rb:4:in `new&apos;'/>
        <level_2_ location='verdict_assert_operator.rb:4:in `test_demo_verdict&apos;'/>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```


### Refute Verdicts


