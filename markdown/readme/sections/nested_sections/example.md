## Nest Sections

This example shows how nest sections in Ruby code.

```nested_sections.rb```:
```ruby
require 'minitest/autorun'
require 'minitest_log'

class Example < MiniTest::Test

  def test_example
    MinitestLog.open(self) do |log|
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
  <summary verdicts='0' failures='0' errors='0'/>
  <section name='First outer'>
    <section name='First inner'/>
    <section name='Second inner'/>
  </section>
  <section name='Second outer'>
    <section name='First inner'/>
    <section name='Second inner'/>
  </section>
</log>
```
