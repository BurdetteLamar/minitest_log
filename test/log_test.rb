require 'test_helper'

# noinspection RubyBlockToMethodReference
class MinitestLogTest < Minitest::Test

  def test_version_exist
    refute_nil ::MinitestLog::VERSION
  end

  def test_new
    exception = assert_raises(RuntimeError) do
      MinitestLog.new('foo.xml')
    end
    store_and_assert('new.txt', exception.message)
  end

  def test_open_no_block
    exception = assert_raises(RuntimeError) do
      MinitestLog.open
    end
    store_and_assert('open_no_block.txt', exception.message)
  end

  def test_open_block
    file_name = 'open_block.xml'
    MinitestLog.open(actual_file_path(file_name)) do |log|
    end
    assert_file(file_name)
  end

  def test_open_default_file_path
    file_path = nil
    MinitestLog.open do |log|
      file_path = log.file_path
      log.put_data('file_path', file_path)
    end
    actual = File.read(file_path)
    File.delete(file_path)
    store_and_assert('open_default_file_path.xml', actual)
  end

  def test_open_file_path
    file_name = 'open_file_path.xml'
    file_path = actual_file_path(file_name)
    MinitestLog.open(file_path) do |log|
      file_path = log.file_path
      log.put_data('file_path', file_path)
    end
    assert_file(file_name)
  end

  def test_open_root_name
    root_name = 'foo'
    file_name = 'open_root_name.xml'
    file_path = actual_file_path(file_name)
    MinitestLog.open(file_path, :root_name => root_name) do |log|
      file_path = log.file_path
      log.put_data('file_path', file_path)
    end
    assert_file(file_name)
  end

  def test_open_xml_indentation
    [-1, 0, 2].each do |indentation|
      file_name = "open_xml_indentation.#{indentation}.xml"
      file_path = actual_file_path(file_name)
      MinitestLog.open(file_path, :xml_indentation => indentation) do |log|
        log.section('Section') do
          log.put_data('indentation', indentation)
        end
      end
      assert_file(file_name)
    end

  end

  def test_nested_sections
    file_name = 'nested_sections.xml'
    file_path = actual_file_path(file_name)
    MinitestLog.open(file_path) do |log|
      log.section('Outer') do
        log.put_data('outer_tag', 'Outer text.')
        log.section('Mid') do
          log.put_data('mid_tag', 'Mid text.')
          log.section('Inner') do
            log.put_data('inner_tag', 'Inner text.')
          end
        end
      end
    end
    assert_file(file_name)
  end

  def test_comment
    file_name = 'comment.xml'
    file_path = actual_file_path(file_name)
    MinitestLog.open(file_path) do |log|
      log.comment('My comment.')
    end
    assert_file(file_name)
  end

  def test_uncaught_exception
    file_name = 'uncaught_exception.xml'
    file_path = actual_file_path(file_name)
    MinitestLog.open(file_path) do |log|
      raise RuntimeError.new('Wrong!')
    end
    condition_file(file_path)
    assert_file(file_name)
  end

  def test_put_element
    file_name = 'put_element.xml'
    file_path = actual_file_path(file_name)
    MinitestLog.open(file_path) do |log|
      log.put_element('my_section') do
        log.put_element('my_element', 'my text')
      end
    end
    assert_file(file_name)
  end

  def _test_put(method, obj)
    file_name = "#{method}.xml"
    file_path = actual_file_path(file_name)
    # Test using the given method.
    MinitestLog.open(file_path) do |log|
      log.send(method, method.to_s, obj)
    end
    assert_file(file_name)
    # Test using method :put_
    MinitestLog.open(file_path) do |log|
      log.send(:put_data, method.to_s, obj)
    end
    assert_file(file_name)
  end

  def _test_put_each_with_index(method, obj)
    _test_put(method, obj)
  end

  def test_put_each_with_index
    arg = [:a, :aa, :aaa]
    _test_put_each_with_index(:put_each_with_index, arg)
  end

  def test_put_array
    arg = [:a, :aa, :aaa]
    _test_put_each_with_index(:put_array, arg)
  end

  def test_put_set
    arg = Set.new([:a, :aa, :aaa])
    _test_put_each_with_index(:put_set, arg)
  end

  def _test_put_each_pair(method, arg)
    _test_put(method, arg)
  end

  def test_put_each_pair
    arg = {:a => 0, :b => 1}
    _test_put_each_pair(:put_each_pair, arg)
  end

  def test_put_each
    each = %w/first second third/
    each.instance_eval('undef :each_with_index')
    _test_put(:put_each, each)
  end

  def test_put_hash
    arg = {:a => 0, :b => 1}
    _test_put_each_pair(:put_hash, arg)
  end

  def test_put_to_s
    _test_put(:put_to_s, 3.14159)
  end

  def test_put_string
    _test_put(:put_string, 'Foo')
  end

  def test_put_inspect
    inspect = (0..3)
    inspect.instance_eval('undef :each_with_index')
    inspect.instance_eval('undef :each')
    inspect.instance_eval('undef :to_s')
    _test_put(:put_inspect, inspect)
  end

  def actual_file_path(file_name)
    File.join(
        'test',
        'actual',
        file_name
    )
  end

  def expected_file_path(file_name)
    File.join(
        'test',
        'expected',
        file_name
    )
  end

  def store_and_assert(file_name, actual_content)
    File.write(actual_file_path(file_name), actual_content)
    assert_file(file_name)
  end

  def assert_file(file_name)
    expected_content = File.readlines(expected_file_path(file_name))
    actual_content = File.readlines(actual_file_path(file_name))
    diff = Diff::LCS.diff(expected_content, actual_content)
    assert_empty(diff)
  end

  def condition_file(file_path)
    content = File.read(file_path)
    timestamp_regexp = /timestamp='\d{4}-\d{2}-\d{2}-\w{3}-\d{2}\.\d{2}\.\d{2}\.\d{3}'/
    conditioned_content = content.gsub(timestamp_regexp, "timestamp=''")
    File.write(file_path, conditioned_content)
  end

end
