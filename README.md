# MinitestLog

[![Gem Version](https://badge.fury.io/rb/minitest_log.svg)](https://badge.fury.io/rb/minitest_log)

```MinitestLog``` gives you three things:

- **Nested sections:**  Use nested sections to structure your test (and, importantly, its log), so that the test can "tell its story" clearly.
- **Data explication:**  Use data-logging methods to log objects. Most collections (```Array```, ```Hash```, etc.) are automatically logged in detail.
- **(And of course) Verdicts:** Use verdict methods to express assertions.  Details for the verdict are logged, whether passed or failed.

## Installation

```sh
gem install minitest_log
```

## Contents
- [Logs and Sections](#logs-and-sections)
  - [Nested Sections](#nested-sections)
  - [Text](#text)
  - [Formatted Text](#formatted-text)
  - [Attributes](#attributes)
  - [Timestamps and Durations](#timestamps-and-durations)
  - [Rescue](#rescue)
  - [Unrescued Exception](#unrescued-exception)
  - [Potpourri](#potpourri)
  - [Custom Elements](#custom-elements)
  - [Options](#options)
    - [Root Name](#root-name)
    - [XML Indentation](#xml-indentation)
    - [Summary](#summary)
    - [Error Verdict](#error-verdict)
    - [Backtrace Filter](#backtrace-filter)
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
    - [verdict_assert_output?](#verdict_assert_output)
    - [verdict_assert_predicate?](#verdict_assert_predicate)
    - [verdict_assert_raises?](#verdict_assert_raises)
    - [verdict_assert_respond_to?](#verdict_assert_respond_to)
    - [verdict_assert_same?](#verdict_assert_same)
    - [verdict_assert_silent?](#verdict_assert_silent)
    - [verdict_assert_throws?](#verdict_assert_throws)
  - [Refute Verdicts](#refute-verdicts)
    - [verdict_refute?](#verdict_refute)
    - [verdict_refute_empty?](#verdict_refute_empty)
    - [verdict_refute_equal?](#verdict_refute_equal)
    - [verdict_refute_in_delta?](#verdict_refute_in_delta)
    - [verdict_refute_in_epsilon?](#verdict_refute_in_epsilon)
    - [verdict_refute_includes?](#verdict_refute_includes)
    - [verdict_refute_instance_of?](#verdict_refute_instance_of)
    - [verdict_refute_kind_of?](#verdict_refute_kind_of)
    - [verdict_refute_match?](#verdict_refute_match)
    - [verdict_refute_nil?](#verdict_refute_nil)
    - [verdict_refute_operator?](#verdict_refute_operator)
    - [verdict_refute_predicate?](#verdict_refute_predicate)
    - [verdict_refute_respond_to?](#verdict_refute_respond_to)
    - [verdict_refute_same?](#verdict_refute_same)
- [Tips](#tips)
  - [Use Short Verdict Aliases](#use-short-verdict-aliases)
  - [Avoid Failure Clutter](#avoid-failure-clutter)
  - [Facilitate Post-Processing](#facilitate-post-processing)
- [Oh, and Tests](#oh-and-tests)

## Logs and Sections

### Nested Sections

Use nested sections to give structure to your test -- and its log.

In calling method ```section```, the first argument is the section name.  Any following string arguments become text.

```example.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('My nested sections', 'Sections can nest.') do
        log.section('Outer', 'Outer section.') do
          log.section('Mid', 'Mid-level section') do
            log.section('Inner', 'Inner section.')
            log.section('Another','Another inner section.')
          end
        end
      end
    end
  end
end
```

```log.xml```:
```xml
<log>
  <section_ name='My nested sections'>
    Sections can nest.
    <section_ name='Outer'>
      Outer section.
      <section_ name='Mid'>
        Mid-level section
        <section_ name='Inner'>
          Inner section.
        </section_>
        <section_ name='Another'>
          Another inner section.
        </section_>
      </section_>
    </section_>
  </section_>
</log>
```

### Text

Put text onto a section by calling method ```section``` with string arguments.

As before, the first argument is the section name; other string arguments become text.

Multiple string arguments are concatenated into the text.

Note that you can also put text onto a section by calling method ```put_data```.  See [Data](#data) below.

```example.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('My section', 'Text for my section.') do
        log.section('Another section', 'Text for another section.', ' More text.')
      end
    end
  end
end
```

```log.xml```:
```xml
<log>
  <section_ name='My section'>
    Text for my section.
    <section_ name='Another section'>
      Text for another section. More text.
    </section_>
  </section_>
</log>
```


### Formatted Text

Put formatted text onto a section by calling method ```put_pre```.

Whitespace, including newlines, is preserved.

The formatted text in the log is more readable if it begins and ends with suitable whitespace, so by default the method displays the text with enhanced whitespace if needed.

You can specify ```verbatim = true``` to suppress the enhancement.

```example.rb```:
```ruby
require 'minitest_log'
class Example < MiniTest::Test

  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('Line of text with leading and trailing whitespace') do
        log.put_pre('  Text.  ')
      end
      text = <<EOT
Text
and
more
text.
EOT
      log.section('Multiline text with enhanced whitespace') do
        log.put_pre(text)
      end
      log.section('Multiline text without without enhanced whitespace') do
        log.put_pre(text, verbatim = true)
      end
    end
  end
end
```

```log.xml```:
```xml
<log>
  <section_ name='Line of text with leading and trailing whitespace'>
    <![CDATA[
  Text.  
]]>
  </section_>
  <section_ name='Multiline text with enhanced whitespace'>
    <![CDATA[
Text
and
more
text.
]]>
  </section_>
  <section_ name='Multiline text without without enhanced whitespace'>
    <![CDATA[Text
and
more
text.]]>
  </section_>
</log>
```


### Attributes

Put attributes onto a section by calling ```section``` with hash arguments.

Each name/value pair in a hash becomes an attribute in the log section element.

The first argument is always the section name.  Following hash arguments become attributes.

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

### Timestamps and Durations

Use symbol ```:timestamp``` or ```:duration``` to add a timestamp or a duration to a section.

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
  <section_ name='My section with timestamp' timestamp='2019-05-09-Thu-09.33.56.076'>
    Section with timestamp.
  </section_>
  <section_ name='My section with duration' duration_seconds='0.500'>
    Section with duration.
  </section_>
  <section_ name='My section with both' timestamp='2019-05-09-Thu-09.33.56.577' duration_seconds='0.501'>
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
        <![CDATA[
example.rb:6:in `block (2 levels) in test_example'
example.rb:5:in `block in test_example'
example.rb:4:in `new'
example.rb:4:in `test_example'
]]>
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
    <uncaught_exception_ timestamp='2019-05-09-Thu-09.33.57.495' class='RuntimeError'>
      <message_>
        Boo!
      </message_>
      <backtrace_>
        <![CDATA[
example.rb:6:in `block (2 levels) in test_example'
example.rb:5:in `block in test_example'
example.rb:4:in `new'
example.rb:4:in `test_example'
]]>
      </backtrace_>
    </uncaught_exception_>
  </section_>
</log>
```

### Potpourri

So far, examples for method ```section``` have emphasized one thing at a time.

A call to method ```section``` begins always with the section name, but after that it can have any number and any types of arguments.

Note that:

- Multiple string arguments are concatenated, left to right, to form one string in the log.
- Each hash argument's name/value pairs are used to form attributes in the log.
- Symbols ```:timestamp```, ```:duration```, and ```:rescue``` may appear anywhere among the arguments.  Duplicates are ignored.

```example.rb```:
```ruby
require 'minitest_log'
class Test < Minitest::Test
  def test_demo
    MinitestLog.new('log.xml') do |log|
      log.section(
          'Section with potpourri of arguments',
          # Not that you would ever want to do this. :-)
          :duration,
          'Word',
          {:a => 0, :b => 1},
          :timestamp,
          ' More words',
          {:c => 2, :d => 3},
          :rescue,
      ) do
        sleep(0.5)
        raise Exception.new('Boo!')
      end
    end
  end
end
```

```log.xml```:
```xml
<log>
  <section_ name='Section with potpourri of arguments' a='0' b='1' timestamp='2019-05-09-Thu-09.33.54.458' c='2' d='3' duration_seconds='0.502'>
    Word More words
    <rescued_exception_ class='Exception' message='Boo!'>
      <backtrace_>
        <![CDATA[
example.rb:17:in `block (2 levels) in test_demo'
example.rb:5:in `block in test_demo'
example.rb:4:in `new'
example.rb:4:in `test_demo'
]]>
      </backtrace_>
    </rescued_exception_>
  </section_>
</log>
```


### Custom Elements

Use method ```put_element(name, *args)``` to put custom elements onto the log.  The name must be text that can become a legal XML element name.

Method ```section``` just calls ```put_element``` with the name ```section```, so the remaining allowed ```*args``` are the same for both :

- A string becomes text.
- A hash-like object becomes attributes.
- An array-like object becomes a numbered list.

A call to ```put_element``` with no block generates a childless element -- one with no sub-elements (though it may still have text).

Create sub-elements for a custom element by calling ```put_element``` with a block.  Whatever elements are generated by the block become sub-elements of the custom element.

```example.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_example
    MinitestLog.new('log.xml') do |log|
      log.section('Custom elements with no children') do
        log.put_element('childless_element')
        log.put_element('childless_element_with_text', 'Text for this element.')
        log.put_element('childless_element_with_attributes', {:a => 0, :b => 1})
      end
      log.section('Custom elements with children') do
        log.put_element('parent_element') do
          log.put_element('child_element')
        end
        log.put_element('parent_element_with_text', 'Text for this element.') do
          log.put_element('child_element')
        end
        log.put_element('parent_element_with_attributes', {:a => 0, :b => 1}) do
          log.put_element('child_element')
        end
      end
    end
  end
end
```

```log.xml```:
```xml
<log>
  <section_ name='Custom elements with no children'>
    <childless_element/>
    <childless_element_with_text>
      Text for this element.
    </childless_element_with_text>
    <childless_element_with_attributes a='0' b='1'/>
  </section_>
  <section_ name='Custom elements with children'>
    <parent_element>
      <child_element/>
    </parent_element>
    <parent_element_with_text>
      Text for this element.
      <child_element/>
    </parent_element_with_text>
    <parent_element_with_attributes a='0' b='1'>
      <child_element/>
    </parent_element_with_attributes>
  </section_>
</log>
```


### Options

#### Root Name

The default name for the XML root element is ```log```.

Override that name by specifying option ```:root_name```.

```root_name.rb```:
```ruby
require 'minitest_log'
class Test < Minitest::Test
  def test_demo
    MinitestLog.new('default_root_name.xml') do |log|
      log.section('This log has the default root name.')
    end
    MinitestLog.new('custom_root_name.xml', :root_name => 'my_root_name') do |log|
      log.section('This log has a custom root name.')
    end
  end
end
```

```default_root_name.xml```:
```xml
<log>
  <section_ name='This log has the default root name.'/>
</log>
```

```custom_root_name.xml```:
```xml
<my_root_name>
  <section_ name='This log has a custom root name.'/>
</my_root_name>
```

#### XML Indentation

The default XML indentation is 2 spaces.

Override that value by specifying option ```xml_indentation```.

An indentation value of ```0``` puts each line of the log at the left, with no indentation.

An indentation value of ```-1``` puts the entire log on one line, with no whitespace at all.  This format is best for logs that will be parsed in post-processing.

Note that many applications that display XML will ignore the indentation altogether, so in general it matters only when the raw XML is read (by a person) or parsed.

```xml_indentation.rb```:
```ruby
require 'minitest_log'
class Test < Minitest::Test
  def test_demo
    MinitestLog.new('default_xml_indentation.xml') do |log|
      log.section('This log has the default XML indentation (2 spaces).') do
        log.section('See?')
      end
    end
    MinitestLog.new('xml_indentation_0.xml', :xml_indentation => 0) do |log|
      log.section('This log has an XML indentation of 0 (no indentation).') do
        log.section('See?')
      end
    end
    MinitestLog.new('xml_indentation_-1.xml', :xml_indentation => -1) do |log|
      log.section('This log has an XML indentation of -1 (all on one line).') do
        log.section('See?')
      end
    end
  end
end
```

```default_xml_indentation.xml```:
```xml
<log>
  <section_ name='This log has the default XML indentation (2 spaces).'>
    <section_ name='See?'/>
  </section_>
</log>
```

```xml_indentation_0.xml```:
```xml
<log>
<section_ name='This log has an XML indentation of 0 (no indentation).'>
<section_ name='See?'/>
</section_>
</log>
```

```xml_indentation_-1.xml```:
```xml
<log><section_ name='This log has an XML indentation of -1 (all on one line).'><section_ name='See?'/></section_></log>
```

#### Summary

By default, the log does not have a summary: counts of total verdicts, failed verdicts, and errors.

Override that behavior by specifying option ```:summary``` as ```true```.  This causes the log to begin with a summary.

```summary.rb```:
```ruby
require 'minitest_log'
class Test < Minitest::Test
  def test_demo
    MinitestLog.new('no_summary.xml') do |log|
      log.section('This log has no summary.') do
        populate_the_log(log)
      end
    end
    MinitestLog.new('summary.xml', :summary => true) do |log|
      log.section('This log has a summary.') do
        populate_the_log(log)
      end
    end
  end
  def populate_the_log(log)
    log.verdict_assert?(:pass, true)
    log.verdict_assert?(:fail, false)
    log.section('My error-producing section', :rescue) do
      raise Exception.new('Boo!')
    end
  end
end
```

```no_summary.xml```:
```xml
<log>
  <section_ name='This log has no summary.'>
    <verdict_ method='verdict_assert?' outcome='passed' id='pass'>
      <actual_ class='TrueClass' value='true'/>
    </verdict_>
    <verdict_ method='verdict_assert?' outcome='failed' id='fail'>
      <actual_ class='FalseClass' value='false'/>
      <exception_ class='Minitest::Assertion' message='Expected false to be truthy.'>
        <backtrace_>
          <![CDATA[
summary.rb:17:in `populate_the_log'
summary.rb:6:in `block (2 levels) in test_demo'
summary.rb:5:in `block in test_demo'
summary.rb:4:in `new'
summary.rb:4:in `test_demo'
]]>
        </backtrace_>
      </exception_>
    </verdict_>
    <section_ name='My error-producing section'>
      <rescued_exception_ class='Exception' message='Boo!'>
        <backtrace_>
          <![CDATA[
summary.rb:19:in `block in populate_the_log'
summary.rb:18:in `populate_the_log'
summary.rb:6:in `block (2 levels) in test_demo'
summary.rb:5:in `block in test_demo'
summary.rb:4:in `new'
summary.rb:4:in `test_demo'
]]>
        </backtrace_>
      </rescued_exception_>
    </section_>
  </section_>
</log>
```

```summary.xml```:
```xml
<log>
  <summary_ verdicts='2' failures='1' errors='1'/>
  <section_ name='This log has a summary.'>
    <verdict_ method='verdict_assert?' outcome='passed' id='pass'>
      <actual_ class='TrueClass' value='true'/>
    </verdict_>
    <verdict_ method='verdict_assert?' outcome='failed' id='fail'>
      <actual_ class='FalseClass' value='false'/>
      <exception_ class='Minitest::Assertion' message='Expected false to be truthy.'>
        <backtrace_>
          <![CDATA[
summary.rb:17:in `populate_the_log'
summary.rb:11:in `block (2 levels) in test_demo'
summary.rb:10:in `block in test_demo'
summary.rb:9:in `new'
summary.rb:9:in `test_demo'
]]>
        </backtrace_>
      </exception_>
    </verdict_>
    <section_ name='My error-producing section'>
      <rescued_exception_ class='Exception' message='Boo!'>
        <backtrace_>
          <![CDATA[
summary.rb:19:in `block in populate_the_log'
summary.rb:18:in `populate_the_log'
summary.rb:11:in `block (2 levels) in test_demo'
summary.rb:10:in `block in test_demo'
summary.rb:9:in `new'
summary.rb:9:in `test_demo'
]]>
        </backtrace_>
      </rescued_exception_>
    </section_>
  </section_>
</log>
```

#### Error Verdict

By default, the log does not have an error verdict: a generated verdict that expects the error count to be 0.

Override that behavior by specifying option ```:error_verdict``` as ```true```.  This causes the log to end with an error verdict.

This verdict may be useful when a log has errors, but no failed verdicts.

```error_verdict.rb```:
```ruby
require 'minitest_log'
class Test < Minitest::Test
  def test_demo
    MinitestLog.new('no_error_verdict.xml') do |log|
      log.section('This log has no error verdict.') do
        populate_the_log(log)
      end
    end
    MinitestLog.new('error_verdict.xml', :error_verdict => true) do |log|
      log.section('This log has an error verdict.') do
        populate_the_log(log)
      end
    end
  end
  def populate_the_log(log)
    log.verdict_assert?(:pass, true)
    log.verdict_assert?(:fail, false)
    log.section('My error-producing section', :rescue) do
      raise Exception.new('Boo!')
    end
  end
end
```

```no_error_verdict.xml```:
```xml
<log>
  <section_ name='This log has no error verdict.'>
    <verdict_ method='verdict_assert?' outcome='passed' id='pass'>
      <actual_ class='TrueClass' value='true'/>
    </verdict_>
    <verdict_ method='verdict_assert?' outcome='failed' id='fail'>
      <actual_ class='FalseClass' value='false'/>
      <exception_ class='Minitest::Assertion' message='Expected false to be truthy.'>
        <backtrace_>
          <![CDATA[
error_verdict.rb:17:in `populate_the_log'
error_verdict.rb:6:in `block (2 levels) in test_demo'
error_verdict.rb:5:in `block in test_demo'
error_verdict.rb:4:in `new'
error_verdict.rb:4:in `test_demo'
]]>
        </backtrace_>
      </exception_>
    </verdict_>
    <section_ name='My error-producing section'>
      <rescued_exception_ class='Exception' message='Boo!'>
        <backtrace_>
          <![CDATA[
error_verdict.rb:19:in `block in populate_the_log'
error_verdict.rb:18:in `populate_the_log'
error_verdict.rb:6:in `block (2 levels) in test_demo'
error_verdict.rb:5:in `block in test_demo'
error_verdict.rb:4:in `new'
error_verdict.rb:4:in `test_demo'
]]>
        </backtrace_>
      </rescued_exception_>
    </section_>
  </section_>
</log>
```

```error_verdict.xml```:
```xml
<log>
  <section_ name='This log has an error verdict.'>
    <verdict_ method='verdict_assert?' outcome='passed' id='pass'>
      <actual_ class='TrueClass' value='true'/>
    </verdict_>
    <verdict_ method='verdict_assert?' outcome='failed' id='fail'>
      <actual_ class='FalseClass' value='false'/>
      <exception_ class='Minitest::Assertion' message='Expected false to be truthy.'>
        <backtrace_>
          <![CDATA[
error_verdict.rb:17:in `populate_the_log'
error_verdict.rb:11:in `block (2 levels) in test_demo'
error_verdict.rb:10:in `block in test_demo'
error_verdict.rb:9:in `new'
error_verdict.rb:9:in `test_demo'
]]>
        </backtrace_>
      </exception_>
    </verdict_>
    <section_ name='My error-producing section'>
      <rescued_exception_ class='Exception' message='Boo!'>
        <backtrace_>
          <![CDATA[
error_verdict.rb:19:in `block in populate_the_log'
error_verdict.rb:18:in `populate_the_log'
error_verdict.rb:11:in `block (2 levels) in test_demo'
error_verdict.rb:10:in `block in test_demo'
error_verdict.rb:9:in `new'
error_verdict.rb:9:in `test_demo'
]]>
        </backtrace_>
      </rescued_exception_>
    </section_>
  </section_>
  <verdict_ method='verdict_assert_equal?' outcome='failed' id='error_count'>
    <expected_ class='Integer' value='0'/>
    <actual_ class='Integer' value='1'/>
    <exception_ class='Minitest::Assertion' message='Expected: 0'>
      <backtrace_>
        <![CDATA[
error_verdict.rb:9:in `new'
error_verdict.rb:9:in `test_demo'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### Backtrace Filter

By default, a backtrace omits entries containing the token ```minitest```.  This keeps the backtrace focussed on your code instead of the gems' code.

Override that behavior by specifying ioption ```:backtrace_filter``` with a ```Regexp``` object.  Entries matching that pattern will be omitted from the backtrace.

```backtrace_filter.rb```:
```ruby
require 'minitest_log'
class Test < Minitest::Test
  def test_demo
    MinitestLog.new('default_backtrace_filter.xml') do |log|
      fail 'Boo!'
    end
    MinitestLog.new('custom_backtrace_filter.xml', :backtrace_filter => /xxx/) do |log|
      fail 'Boo!'
    end
  end
end
```

```default_backtrace_filter.xml```:
```xml
<log>
  <uncaught_exception_ timestamp='2019-05-09-Thu-09.33.52.638' class='RuntimeError'>
    <message_>
      Boo!
    </message_>
    <backtrace_>
      <![CDATA[
backtrace_filter.rb:5:in `block in test_demo'
backtrace_filter.rb:4:in `new'
backtrace_filter.rb:4:in `test_demo'
]]>
    </backtrace_>
  </uncaught_exception_>
</log>
```

```custom_backtrace_filter.xml```:
```xml
<log>
  <uncaught_exception_ timestamp='2019-05-09-Thu-09.33.52.640' class='RuntimeError'>
    <message_>
      Boo!
    </message_>
    <backtrace_>
      <![CDATA[
backtrace_filter.rb:8:in `block in test_demo'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest_log-0.2.0/lib/minitest_log.rb:59:in `initialize'
backtrace_filter.rb:7:in `new'
backtrace_filter.rb:7:in `test_demo'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest/test.rb:98:in `block (3 levels) in run'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest/test.rb:195:in `capture_exceptions'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest/test.rb:95:in `block (2 levels) in run'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:265:in `time_it'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest/test.rb:94:in `block in run'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:360:in `on_signal'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest/test.rb:211:in `with_info_handler'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest/test.rb:93:in `run'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:960:in `run_one_method'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:334:in `run_one_method'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:321:in `block (2 levels) in run'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:320:in `each'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:320:in `block in run'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:360:in `on_signal'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:347:in `with_info_handler'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:319:in `run'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:159:in `block in __run'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:159:in `map'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:159:in `__run'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:136:in `run'
C:/Ruby25-x64/lib/ruby/gems/2.5.0/gems/minitest-5.11.3/lib/minitest.rb:63:in `block in autorun'
]]>
    </backtrace_>
  </uncaught_exception_>
</log>
```


## Data

Put data onto the log using method ```:put_data```.

A data object ```obj``` is treated as follows:

- If ```obj.kind_of?(String)```, it is treated as a [String](#strings)
- Otherwise if ```obj.respond_to?(:each_pair)```, it is treated as [Hash-like](#hash-like-objects).
- Otherwise, it ```obj.respond_to?(:each_with_index```, it is treated as [Array-like](#array-like-objects).
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
class Example < Minitest::Test
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
        log.put_data('My regexp', /Bar/)
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
    <data_ name='My regexp' class='Regexp' method=':to_s'>
      (?-mix:Bar)
    </data_>
    <data_ name='My time' class='Time' method=':to_s'>
      2019-05-09 09:33:50 -0500
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

An important difference between an assertion and a verdict is that a failed verdict does not exit the test.  Instead, the verdict method logs the details for the assertion, regardless of the outcome, and continues test execution.

The verdict method returns ```true``` or ```false``` to indicate whether the verdict succeeded or failed.

The arguments for the verdict method and its assert method are the same, except that the verdict method adds a leading verdict identifier:

```ruby
assert_equal(exp, act)

verdict_assert_equal?('verdict_id', exp, act)
```

Like an assertion, a verdict also accepts an optional trailing message string.

The verdict identifier:
- Is commonly a string or a symbol, but may be any object that responds to ```:to_s```.
- Must be unique among the verdict identifiers in its *test method* (but not necessarily in its *test class*.)

Each verdict method has a shorter alias -- ```va``` substituting for ```verdict_assert```, and ```vr``` substituting for ```verdict_refute```:

Example verdict (long form and alias):

```ruby
log.verdict_assert_equal?(:my_verdict_id, exp, act, 'My message')

log.va_equal?(:my_verdict_id, exp, act, 'My message')
```
The shorter alias not only saves keystrokes, but also *really*, *really* helps your editor with code completion.

Verdict methods are described below.  For each, the following is given:

- The method's syntax.
- An example test using the method, including both passing and failing verdicts.
- The log output by the example test.
- Descriptive text, adapted from [docs.ruby-lang.org](https://docs.ruby-lang.org/en/2.1.0/MiniTest/Assertions.html)

### Assert Verdicts

#### verdict_assert?

```ruby
verdict_assert?(id, test, msg = nil)
va?(id, test, msg = nil)
```

Fails unless ```test``` is a true value.

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
        <![CDATA[
verdict_assert.rb:6:in `block in test_demo_verdict'
verdict_assert.rb:4:in `new'
verdict_assert.rb:4:in `test_demo_verdict'
]]>
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
        <![CDATA[
verdict_assert_empty.rb:6:in `block in test_demo_verdict'
verdict_assert_empty.rb:4:in `new'
verdict_assert_empty.rb:4:in `test_demo_verdict'
]]>
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
        <![CDATA[
verdict_assert_equal.rb:6:in `block in test_demo_verdict'
verdict_assert_equal.rb:4:in `new'
verdict_assert_equal.rb:4:in `test_demo_verdict'
]]>
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
      log.verdict_assert_in_delta?(:another_id, 0, 2, 1, 'Another message')
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
  <verdict_ method='verdict_assert_in_delta?' outcome='failed' id='another_id' message='Another message'>
    <expected_ class='Integer' value='0'/>
    <actual_ class='Integer' value='2'/>
    <delta_ class='Integer' value='1'/>
    <exception_ class='Minitest::Assertion' message='Expected |0 - 2| (2) to be &lt;= 1.'>
      <backtrace_>
        <![CDATA[
verdict_assert_in_delta.rb:6:in `block in test_demo_verdict'
verdict_assert_in_delta.rb:4:in `new'
verdict_assert_in_delta.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
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
  def test_demo_verdict
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
        <![CDATA[
verdict_assert_in_epsilon.rb:6:in `block in test_demo_verdict'
verdict_assert_in_epsilon.rb:4:in `new'
verdict_assert_in_epsilon.rb:4:in `test_demo_verdict'
]]>
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
        <![CDATA[
verdict_assert_includes.rb:6:in `block in test_demo_verdict'
verdict_assert_includes.rb:4:in `new'
verdict_assert_includes.rb:4:in `test_demo_verdict'
]]>
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
    <exception_ class='Minitest::Assertion' message='Expected &quot;my_string&quot; to be an instance of Integer, not String.'>
      <backtrace_>
        <![CDATA[
verdict_assert_instance_of.rb:6:in `block in test_demo_verdict'
verdict_assert_instance_of.rb:4:in `new'
verdict_assert_instance_of.rb:4:in `test_demo_verdict'
]]>
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
        <![CDATA[
verdict_assert_kind_of.rb:6:in `block in test_demo_verdict'
verdict_assert_kind_of.rb:4:in `new'
verdict_assert_kind_of.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_match?

```ruby
verdict_assert_match?(id, matcher, obj, msg = nil)
va_match?(id, matcher, obj, msg = nil)
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
    <exception_ class='Minitest::Assertion' message='Expected /foo/ to match &quot;feed&quot;.'>
      <backtrace_>
        <![CDATA[
verdict_assert_match.rb:6:in `block in test_demo_verdict'
verdict_assert_match.rb:4:in `new'
verdict_assert_match.rb:4:in `test_demo_verdict'
]]>
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
      log.verdict_assert_nil?(:one_id, nil, 'One message')
      log.verdict_assert_nil?(:another_id, :a, 'Another message')
    end
  end
end
```

```verdict_assert_nil.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_nil?' outcome='passed' id='one_id' message='One message'>
    <actual_ class='NilClass' value='nil'/>
  </verdict_>
  <verdict_ method='verdict_assert_nil?' outcome='failed' id='another_id' message='Another message'>
    <actual_ class='Symbol' value=':a'/>
    <exception_ class='Minitest::Assertion' message='Expected :a to be nil.'>
      <backtrace_>
        <![CDATA[
verdict_assert_nil.rb:6:in `block in test_demo_verdict'
verdict_assert_nil.rb:4:in `new'
verdict_assert_nil.rb:4:in `test_demo_verdict'
]]>
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
        <![CDATA[
verdict_assert_operator.rb:6:in `block in test_demo_verdict'
verdict_assert_operator.rb:4:in `new'
verdict_assert_operator.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_output?

```ruby
verdict_assert_output?(id, stdout = nil, stderr = nil) { || ... }
va_output?(id, stdout = nil, stderr = nil) { || ... }
```

Fails if ```stdout``` or ```stderr``` do not output the expected results. Pass in ```nil``` if you don't care about that streams output. Pass in ```''``` if you require it to be silent. Pass in a regexp if you want to pattern match.

NOTE: this uses capture_io, not capture_subprocess_io.

```verdict_assert_output.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_output.xml') do |log|
      log.verdict_assert_output?(:one_id, stdout = 'Foo', stderr = 'Bar') do
        $stdout.write('Foo')
        $stderr.write('Bar')
      end
      log.verdict_assert_output?(:another_id, stdout = 'Bar', stderr = 'Foo') do
        $stdout.write('Foo')
        $stderr.write('Bar')
      end
    end
  end
end
```

```verdict_assert_output.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_output?' outcome='passed' id='one_id'>
    <stdout_ class='String' value='&quot;Foo&quot;'/>
    <stderr_ class='String' value='&quot;Bar&quot;'/>
  </verdict_>
  <verdict_ method='verdict_assert_output?' outcome='failed' id='another_id'>
    <stdout_ class='String' value='&quot;Bar&quot;'/>
    <stderr_ class='String' value='&quot;Foo&quot;'/>
    <exception_ class='Minitest::Assertion' message='In stderr.'>
      <backtrace_>
        <![CDATA[
verdict_assert_output.rb:9:in `block in test_demo_verdict'
verdict_assert_output.rb:4:in `new'
verdict_assert_output.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_predicate?

```ruby
verdict_assert_predicate?(id, o1, op, msg = nil)
va_predicate?(id, o1, op, msg = nil)
```

For testing with predicates.

```verdict_assert_predicate.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_predicate.xml') do |log|
      log.verdict_assert_predicate?(:one_id, '', :empty?, 'One message')
      log.verdict_assert_predicate?(:another_id, 'x', :empty?, 'Another message')
    end
  end
end
```

```verdict_assert_predicate.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_predicate?' outcome='passed' id='one_id' message='One message'>
    <object_ class='String' value='&quot;&quot;'/>
    <operator_ class='Symbol' value=':empty?'/>
  </verdict_>
  <verdict_ method='verdict_assert_predicate?' outcome='failed' id='another_id' message='Another message'>
    <object_ class='String' value='&quot;x&quot;'/>
    <operator_ class='Symbol' value=':empty?'/>
    <exception_ class='Minitest::Assertion' message='Expected &quot;x&quot; to be empty?.'>
      <backtrace_>
        <![CDATA[
verdict_assert_predicate.rb:6:in `block in test_demo_verdict'
verdict_assert_predicate.rb:4:in `new'
verdict_assert_predicate.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_raises?

```ruby
verdict_assert_raises?(id, *exp) { || ... }
va_raises?(id, *exp) { || ... }
```

Fails unless the block raises one of ```exp```. Returns the exception matched so you can check the message, attributes, etc.

```verdict_assert_raises.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_raises.xml') do |log|
      log.verdict_assert_raises?(:one_id, RuntimeError, 'One message') do
        raise RuntimeError.new('Boo!')
      end
      log.verdict_assert_raises?(:another_id, RuntimeError, 'Another message') do
        raise Exception.new('Boo!')
      end
    end
  end
end
```

```verdict_assert_raises.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_raises?' outcome='passed' id='one_id' message='One message'>
    <error_class_ class='Class' value='RuntimeError'/>
  </verdict_>
  <verdict_ method='verdict_assert_raises?' outcome='failed' id='another_id' message='Another message'>
    <error_class_ class='Class' value='RuntimeError'/>
    <exception_ class='Minitest::Assertion' message='[RuntimeError] exception expected, not'>
      <backtrace_>
        <![CDATA[
verdict_assert_raises.rb:8:in `block in test_demo_verdict'
verdict_assert_raises.rb:4:in `new'
verdict_assert_raises.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_respond_to?

```ruby
verdict_assert_respond_to?(id, obj, meth, msg = nil)
va_respond_to?(id, obj, meth, msg = nil)
```

Fails unless ```obj``` responds to ```meth```.

```verdict_assert_respond_to.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_respond_to.xml') do |log|
      log.verdict_assert_respond_to?(:one_id, 0, :succ, 'One message')
      log.verdict_assert_respond_to?(:another_id, 0, :empty?, 'Another message')
    end
  end
end
```

```verdict_assert_respond_to.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_respond_to?' outcome='passed' id='one_id' message='One message'>
    <object_ class='Integer' value='0'/>
    <method_ class='Symbol' value=':succ'/>
  </verdict_>
  <verdict_ method='verdict_assert_respond_to?' outcome='failed' id='another_id' message='Another message'>
    <object_ class='Integer' value='0'/>
    <method_ class='Symbol' value=':empty?'/>
    <exception_ class='Minitest::Assertion' message='Expected 0 (Integer) to respond to #empty?.'>
      <backtrace_>
        <![CDATA[
verdict_assert_respond_to.rb:6:in `block in test_demo_verdict'
verdict_assert_respond_to.rb:4:in `new'
verdict_assert_respond_to.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_same?

```ruby
verdict_assert_same?(id, exp, act, msg = nil)
va_same?(id, exp, act, msg = nil)
```

Fails unless ```exp``` and ```act``` are ```equal?```.

```verdict_assert_same.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_same.xml') do |log|
      log.verdict_assert_same?(:one_id, :foo, :foo, 'One message')
      log.verdict_assert_same?(:another_id, 'foo', 'foo', 'Another message')
    end
  end
end
```

```verdict_assert_same.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_same?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Symbol' value=':foo'/>
    <actual_ class='Symbol' value=':foo'/>
  </verdict_>
  <verdict_ method='verdict_assert_same?' outcome='failed' id='another_id' message='Another message'>
    <expected_ class='String' value='&quot;foo&quot;'/>
    <actual_ class='String' value='&quot;foo&quot;'/>
    <exception_ class='Minitest::Assertion' message='Expected &quot;foo&quot; (oid=27804000) to be the same as &quot;foo&quot; (oid=27804040).'>
      <backtrace_>
        <![CDATA[
verdict_assert_same.rb:6:in `block in test_demo_verdict'
verdict_assert_same.rb:4:in `new'
verdict_assert_same.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_silent?

```ruby
verdict_assert_silent?(id) { || ... }
va_silent?(id) { || ... }
```

Fails if the block outputs anything to ```stderr``` or ```stdout```.

```verdict_assert_silent.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_silent.xml') do |log|
      log.verdict_assert_silent?(:one_id) do
      end
      log.verdict_assert_silent?(:another_id) do
        $stdout.write('Foo')
      end
    end
  end
end
```

```verdict_assert_silent.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_silent?' outcome='passed' id='one_id'/>
  <verdict_ method='verdict_assert_silent?' outcome='failed' id='another_id'>
    <exception_ class='Minitest::Assertion' message='In stdout.'>
      <backtrace_>
        <![CDATA[
verdict_assert_silent.rb:7:in `block in test_demo_verdict'
verdict_assert_silent.rb:4:in `new'
verdict_assert_silent.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_assert_throws?

```ruby
verdict_assert_throws?(id, sym, msg = nil) { || ... } 
va_throws?(id, sym, msg = nil) { || ... } 
```

Fails unless the block throws ```sym```.

```verdict_assert_throws.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_assert_throws.xml') do |log|
      log.verdict_assert_throws?(:one_id, :foo, 'One message') do
        throw :foo
      end
      log.verdict_assert_throws?(:another_id, :foo, 'Another message') do
        throw :bar
      end
    end
  end
end
```

```verdict_assert_throws.xml```:
```xml
<log>
  <verdict_ method='verdict_assert_throws?' outcome='passed' id='one_id' message='One message'>
    <error_class_ class='Symbol' value=':foo'/>
  </verdict_>
  <verdict_ method='verdict_assert_throws?' outcome='failed' id='another_id' message='Another message'>
    <error_class_ class='Symbol' value=':foo'/>
    <exception_ class='Minitest::Assertion' message='Expected :foo to have been thrown, not :bar.'>
      <backtrace_>
        <![CDATA[
verdict_assert_throws.rb:8:in `block in test_demo_verdict'
verdict_assert_throws.rb:4:in `new'
verdict_assert_throws.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```


### Refute Verdicts

#### verdict_refute?

```ruby
verdict_refute?(id, test, msg = nil)
vr?(id, test, msg = nil)
```

Fails if ```test``` is a true value.

```verdict_refute.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute.xml') do |log|
      log.verdict_refute?(:one_id, false, 'One message')
      log.verdict_refute?(:another_id, true, 'Another message')
    end
  end
end
```

```verdict_refute.xml```:
```xml
<log>
  <verdict_ method='verdict_refute?' outcome='passed' id='one_id' message='One message'>
    <actual_ class='FalseClass' value='false'/>
  </verdict_>
  <verdict_ method='verdict_refute?' outcome='failed' id='another_id' message='Another message'>
    <actual_ class='TrueClass' value='true'/>
    <exception_ class='Minitest::Assertion' message='Expected true to not be truthy.'>
      <backtrace_>
        <![CDATA[
verdict_refute.rb:6:in `block in test_demo_verdict'
verdict_refute.rb:4:in `new'
verdict_refute.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_refute_empty?

```ruby
verdict_refute_empty?(id, obj, msg = nil)
vr_empty?(id, obj, msg = nil)
```

Fails if ```obj``` is empty.

```verdict_refute_empty.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_empty.xml') do |log|
      log.verdict_refute_empty?(:one_id, [:a], 'One message')
      log.verdict_refute_empty?(:another_id, [], 'Another message')
    end
  end
end
```

```verdict_refute_empty.xml```:
```xml
<log>
  <verdict_ method='verdict_refute_empty?' outcome='passed' id='one_id' message='One message'>
    <actual_ class='Array' value='[:a]'/>
  </verdict_>
  <verdict_ method='verdict_refute_empty?' outcome='failed' id='another_id' message='Another message'>
    <actual_ class='Array' value='[]'/>
    <exception_ class='Minitest::Assertion' message='Expected [] to not be empty.'>
      <backtrace_>
        <![CDATA[
verdict_refute_empty.rb:6:in `block in test_demo_verdict'
verdict_refute_empty.rb:4:in `new'
verdict_refute_empty.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_refute_equal?

```ruby
verdict_refute_equal?(id, exp, act, msg = nil)
vr_equal?(id, exp, act, msg = nil)
```
Fails if ```exp == act```.

For floats use verdict_refute_in_delta?.

```verdict_refute_equal.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_equal.xml') do |log|
      log.verdict_refute_equal?(:one_id, 0, 1, 'One message')
      log.verdict_refute_equal?(:another_id, 0, 0, 'Another message')
    end
  end
end
```

```verdict_refute_equal.xml```:
```xml
<log>
  <verdict_ method='verdict_refute_equal?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Integer' value='0'/>
    <actual_ class='Integer' value='1'/>
  </verdict_>
  <verdict_ method='verdict_refute_equal?' outcome='failed' id='another_id' message='Another message'>
    <expected_ class='Integer' value='0'/>
    <actual_ class='Integer' value='0'/>
    <exception_ class='Minitest::Assertion' message='Expected 0 to not be equal to 0.'>
      <backtrace_>
        <![CDATA[
verdict_refute_equal.rb:6:in `block in test_demo_verdict'
verdict_refute_equal.rb:4:in `new'
verdict_refute_equal.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_refute_in_delta?

```ruby
verdict_refute_in_delta?(id, exp, act, delta = 0.001, msg = nil)
vr_in_delta?(id, exp, act, delta = 0.001, msg = nil)
````

For comparing Floats. Fails if ```exp``` is within ```delta``` of ```act```.

```verdict_refute_in_delta.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_in_delta.xml') do |log|
      log.verdict_refute_in_delta?(:one_id, 0, 2, 1, 'One message')
      log.verdict_refute_in_delta?(:another_id, 0, 0, 1, 'Another message')
    end
  end
end
```

```verdict_refute_in_delta.xml```:
```xml
<log>
  <verdict_ method='verdict_refute_in_delta?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Integer' value='0'/>
    <actual_ class='Integer' value='2'/>
    <delta_ class='Integer' value='1'/>
  </verdict_>
  <verdict_ method='verdict_refute_in_delta?' outcome='failed' id='another_id' message='Another message'>
    <expected_ class='Integer' value='0'/>
    <actual_ class='Integer' value='0'/>
    <delta_ class='Integer' value='1'/>
    <exception_ class='Minitest::Assertion' message='Expected |0 - 0| (0) to not be &lt;= 1.'>
      <backtrace_>
        <![CDATA[
verdict_refute_in_delta.rb:6:in `block in test_demo_verdict'
verdict_refute_in_delta.rb:4:in `new'
verdict_refute_in_delta.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_refute_in_epsilon?

```ruby
verdict_ refute_in_epsilon?(id, a, b, epsilon = 0.001, msg = nil) 
vr_in_epsilon?(id, a, b, epsilon = 0.001, msg = nil) 
```

For comparing Floats. Fails if ```exp``` and ```act``` have a relative error less than ```epsilon```.

```verdict_refute_in_epsilon.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_in_epsilon.xml') do |log|
      log.verdict_refute_in_epsilon?(:one_id, 3, 2, 0, 'One message')
      log.verdict_refute_in_epsilon?(:another_id, 3, 2, 1, 'Another message')
    end
  end
end
```

```verdict_refute_in_epsilon.xml```:
```xml
<log>
  <verdict_ method='verdict_refute_in_epsilon?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Integer' value='3'/>
    <actual_ class='Integer' value='2'/>
    <epsilon_ class='Integer' value='0'/>
  </verdict_>
  <verdict_ method='verdict_refute_in_epsilon?' outcome='failed' id='another_id' message='Another message'>
    <expected_ class='Integer' value='3'/>
    <actual_ class='Integer' value='2'/>
    <epsilon_ class='Integer' value='1'/>
    <exception_ class='Minitest::Assertion' message='Expected |3 - 2| (1) to not be &lt;= 3.'>
      <backtrace_>
        <![CDATA[
verdict_refute_in_epsilon.rb:6:in `block in test_demo_verdict'
verdict_refute_in_epsilon.rb:4:in `new'
verdict_refute_in_epsilon.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_refute_includes?

```ruby
verdict_refute_includes?(id, collection, obj, msg = nil) 
vr_includes?(id, collection, obj, msg = nil) 
```

Fails if ```collection``` includes ```obj```.

```verdict_refute_includes.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_includes.xml') do |log|
      log.verdict_refute_includes?(:one_id, [:a, :b, :c], :d, 'One message')
      log.verdict_refute_includes?(:another_id, [:a, :b, :c], :b, 'Another message')
    end
  end
end
```

```verdict_refute_includes.xml```:
```xml
<log>
  <verdict_ method='verdict_refute_includes?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Array' value='[:a, :b, :c]'/>
    <actual_ class='Symbol' value=':d'/>
  </verdict_>
  <verdict_ method='verdict_refute_includes?' outcome='failed' id='another_id' message='Another message'>
    <expected_ class='Array' value='[:a, :b, :c]'/>
    <actual_ class='Symbol' value=':b'/>
    <exception_ class='Minitest::Assertion' message='Expected [:a, :b, :c] to not include :b.'>
      <backtrace_>
        <![CDATA[
verdict_refute_includes.rb:6:in `block in test_demo_verdict'
verdict_refute_includes.rb:4:in `new'
verdict_refute_includes.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_refute_instance_of?

```ruby
verdict_refute_instance_of?(id, cls, obj, msg = nil)
vr_instance_of?(id, cls, obj, msg = nil)
```

Fails if ```obj``` is an instance of ```cls```.

```verdict_refute_instance_of.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_instance_of.xml') do |log|
      log.verdict_refute_instance_of?(:one_id, Integer, 'my_string', 'One message')
      log.verdict_refute_instance_of?(:another_id, String, 'my_string', 'another message')
    end
  end
end
```

```verdict_refute_instance_of.xml```:
```xml
<log>
  <verdict_ method='verdict_refute_instance_of?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Class' value='Integer'/>
    <actual_ class='String' value='&quot;my_string&quot;'/>
  </verdict_>
  <verdict_ method='verdict_refute_instance_of?' outcome='failed' id='another_id' message='another message'>
    <expected_ class='Class' value='String'/>
    <actual_ class='String' value='&quot;my_string&quot;'/>
    <exception_ class='Minitest::Assertion' message='Expected &quot;my_string&quot; to not be an instance of String.'>
      <backtrace_>
        <![CDATA[
verdict_refute_instance_of.rb:6:in `block in test_demo_verdict'
verdict_refute_instance_of.rb:4:in `new'
verdict_refute_instance_of.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_refute_kind_of?

```ruby
verdict_refute_kind_of?(id, cls, obj, msg = nil)
vr_kind_of?(id, cls, obj, msg = nil)
```

Fails if ```obj``` is a kind of ```cls```.

```verdict_refute_kind_of.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_kind_of.xml') do |log|
      log.verdict_refute_kind_of?(:one_id, String, 1.0, 'One message')
      log.verdict_refute_kind_of?(:another_id, Numeric, 1.0, 'Another message')
    end
  end
end
```

```verdict_refute_kind_of.xml```:
```xml
<log>
  <verdict_ method='verdict_refute_kind_of?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Class' value='String'/>
    <actual_ class='Float' value='1.0'/>
  </verdict_>
  <verdict_ method='verdict_refute_kind_of?' outcome='failed' id='another_id' message='Another message'>
    <expected_ class='Class' value='Numeric'/>
    <actual_ class='Float' value='1.0'/>
    <exception_ class='Minitest::Assertion' message='Expected 1.0 to not be a kind of Numeric.'>
      <backtrace_>
        <![CDATA[
verdict_refute_kind_of.rb:6:in `block in test_demo_verdict'
verdict_refute_kind_of.rb:4:in `new'
verdict_refute_kind_of.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_refute_match?

```ruby
verdict_refute_match?(id, matcher, obj, msg = nil)
vr_match?(id, matcher, obj, msg = nil)
```

Fails if ```matcher =~ obj```.

```verdict_refute_match.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_match.xml') do |log|
      log.verdict_refute_match?(:one_id, /foo/, 'feed', 'One message')
      log.verdict_refute_match?(:another_id, /foo/, 'food', 'Another message')
    end
  end
end
```

```verdict_refute_match.xml```:
```xml
<log>
  <verdict_ method='verdict_refute_match?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='Regexp' value='/foo/'/>
    <actual_ class='String' value='&quot;feed&quot;'/>
  </verdict_>
  <verdict_ method='verdict_refute_match?' outcome='failed' id='another_id' message='Another message'>
    <expected_ class='Regexp' value='/foo/'/>
    <actual_ class='String' value='&quot;food&quot;'/>
    <exception_ class='Minitest::Assertion' message='Expected /foo/ to not match &quot;food&quot;.'>
      <backtrace_>
        <![CDATA[
verdict_refute_match.rb:6:in `block in test_demo_verdict'
verdict_refute_match.rb:4:in `new'
verdict_refute_match.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_refute_nil?

```ruby
verdict_refute_nil?(id, obj, msg = nil)
vr_nil?(id, obj, msg = nil)
```

Fails if ```obj``` is nil.

```verdict_refute_nil.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_nil.xml') do |log|
      log.verdict_refute_nil?(:one_id, :a, 'One message')
      log.verdict_refute_nil?(:another_id, nil, 'Another message')
    end
  end
end
```

```verdict_refute_nil.xml```:
```xml
<log>
  <verdict_ method='verdict_refute_nil?' outcome='passed' id='one_id' message='One message'>
    <actual_ class='Symbol' value=':a'/>
  </verdict_>
  <verdict_ method='verdict_refute_nil?' outcome='failed' id='another_id' message='Another message'>
    <actual_ class='NilClass' value='nil'/>
    <exception_ class='Minitest::Assertion' message='Expected nil to not be nil.'>
      <backtrace_>
        <![CDATA[
verdict_refute_nil.rb:6:in `block in test_demo_verdict'
verdict_refute_nil.rb:4:in `new'
verdict_refute_nil.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_refute_operator?

```ruby
verdict_refute_operator?(id, o1, op, o2 = UNDEFINED, msg = nil)
vr_operator?(id, o1, op, o2 = UNDEFINED, msg = nil)
````

Fails if ```o1``` is not ```op``` ```o2```.

```verdict_refute_operator.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_operator.xml') do |log|
      log.verdict_refute_operator?(:one_id, 5, :<=, 4, 'One message')
      log.verdict_refute_operator?(:another_id, 3, :<=, 4, 'Another message')
    end
  end
end
```

```verdict_refute_operator.xml```:
```xml
<log>
  <verdict_ method='verdict_refute_operator?' outcome='passed' id='one_id' message='One message'>
    <object_1_ class='Integer' value='5'/>
    <operator_ class='Symbol' value=':&lt;='/>
    <object_2_ class='Integer' value='4'/>
  </verdict_>
  <verdict_ method='verdict_refute_operator?' outcome='failed' id='another_id' message='Another message'>
    <object_1_ class='Integer' value='3'/>
    <operator_ class='Symbol' value=':&lt;='/>
    <object_2_ class='Integer' value='4'/>
    <exception_ class='Minitest::Assertion' message='Expected 3 to not be &lt;= 4.'>
      <backtrace_>
        <![CDATA[
verdict_refute_operator.rb:6:in `block in test_demo_verdict'
verdict_refute_operator.rb:4:in `new'
verdict_refute_operator.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_refute_predicate?

```ruby
verdict_refute_predicate?(id, o1, op, msg = nil)
vr_predicate?(id, o1, op, msg = nil)
```

For testing with predicates.

```verdict_refute_predicate.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_predicate.xml') do |log|
      log.verdict_refute_predicate?(:one_id, 'x', :empty?, 'One message')
      log.verdict_refute_predicate?(:another_id, '', :empty?, 'Another message')
    end
  end
end
```

```verdict_refute_predicate.xml```:
```xml
<log>
  <verdict_ method='verdict_refute_predicate?' outcome='passed' id='one_id' message='One message'>
    <object_ class='String' value='&quot;x&quot;'/>
    <operator_ class='Symbol' value=':empty?'/>
  </verdict_>
  <verdict_ method='verdict_refute_predicate?' outcome='failed' id='another_id' message='Another message'>
    <object_ class='String' value='&quot;&quot;'/>
    <operator_ class='Symbol' value=':empty?'/>
    <exception_ class='Minitest::Assertion' message='Expected &quot;&quot; to not be empty?.'>
      <backtrace_>
        <![CDATA[
verdict_refute_predicate.rb:6:in `block in test_demo_verdict'
verdict_refute_predicate.rb:4:in `new'
verdict_refute_predicate.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_refute_respond_to?

```ruby
verdict_refute_respond_to?(id, obj, meth, msg = nil)
vr_respond_to?(id, obj, meth, msg = nil)
```

Fails if ```obj``` responds to ```meth```.

```verdict_refute_respond_to.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_respond_to.xml') do |log|
      log.verdict_refute_respond_to?(:one_id, 0, :empty?, 'One message')
      log.verdict_refute_respond_to?(:another_id, 0, :succ, 'Another message')
    end
  end
end
```

```verdict_refute_respond_to.xml```:
```xml
<log>
  <verdict_ method='verdict_refute_respond_to?' outcome='passed' id='one_id' message='One message'>
    <object_ class='Integer' value='0'/>
    <method_ class='Symbol' value=':empty?'/>
  </verdict_>
  <verdict_ method='verdict_refute_respond_to?' outcome='failed' id='another_id' message='Another message'>
    <object_ class='Integer' value='0'/>
    <method_ class='Symbol' value=':succ'/>
    <exception_ class='Minitest::Assertion' message='Expected 0 to not respond to succ.'>
      <backtrace_>
        <![CDATA[
verdict_refute_respond_to.rb:6:in `block in test_demo_verdict'
verdict_refute_respond_to.rb:4:in `new'
verdict_refute_respond_to.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```

#### verdict_refute_same?

```ruby
verdict_refute_same?(id, exp, act, msg = nil)
vr_same?(id, exp, act, msg = nil)
```

Fails if ```exp``` is the same (by object identity) as ```act```.

```verdict_refute_same.rb```:
```ruby
require 'minitest_log'
class Example < Minitest::Test
  def test_demo_verdict
    MinitestLog.new('verdict_refute_same.xml') do |log|
      log.verdict_refute_same?(:one_id, 'foo', 'foo', 'One message')
      log.verdict_refute_same?(:another_id, :foo, :foo, 'Another message')
    end
  end
end
```

```verdict_refute_same.xml```:
```xml
<log>
  <verdict_ method='verdict_refute_same?' outcome='passed' id='one_id' message='One message'>
    <expected_ class='String' value='&quot;foo&quot;'/>
    <actual_ class='String' value='&quot;foo&quot;'/>
  </verdict_>
  <verdict_ method='verdict_refute_same?' outcome='failed' id='another_id' message='Another message'>
    <expected_ class='Symbol' value=':foo'/>
    <actual_ class='Symbol' value=':foo'/>
    <exception_ class='Minitest::Assertion' message='Expected :foo (oid=1043228) to not be the same as :foo (oid=1043228).'>
      <backtrace_>
        <![CDATA[
verdict_refute_same.rb:6:in `block in test_demo_verdict'
verdict_refute_same.rb:4:in `new'
verdict_refute_same.rb:4:in `test_demo_verdict'
]]>
      </backtrace_>
    </exception_>
  </verdict_>
</log>
```



## Tips

### Use Short Verdict Aliases

Use the short alias for a verdict method, to:

- Have less source code.
- Allow code-completion to work *much* better (completion select list gets shorter *much* sooner).

Examples:

- ```log.va_equal?```, not ```log.verdict assert_equal?```.
- ```log.vr_empty?```, not ```log.verdict_refute_empty?```.

### Avoid Failure Clutter

Use verdict return values (```true```/```false```) to omit verdicts that would definitely fail.  This can greatly simplify your test results.

In the example below, the test attempts to create a user.  If the create succeeds, the test further validates, then deletes the user.

However, if the create fails, the test does not attempt to validate or delete the user (which attempts would fail, and might raise exceptions).

Thus, assuming a failed create returns ```nil```:

```ruby
user_name = 'Bill Jones'
user = SomeApi.create_user(user_name)
if log.verdict_refute_nil?(:user_created, user)
  log.verdict_assert_equal?(:user_name, user_name, user.name)
  SomeApi.delete_user(user.id)
end
```

### Facilitate Post-Processing

If your logs will be parsed in post-processing, you can make that go smoother by creating the logs with certain options:

- ```:xml_indentation => -1```:  so that there's no log-generated whitespace.  (But you'll still see the same indented display in your browser.)
- ```:summary => true```:  so that the counts are already computed.
- ```:error_verdict => true```: so that a log that has errors will also have at least one failed verdict.

See [Options](#options)

## Oh, and Tests

This project's tests generate 135 [logs and other output files](../../tree/master/test/actual), performing 484 verifications.

- [log_test.rb](../../tree/master/test/log_test.rb)
- [verdict_test.rb](../../tree/master/test/verdict_test.rb)
