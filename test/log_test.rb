require 'test_helper'

class LogTest < Minitest::Test

  include TestHelper

  def test_version_exist
    refute_nil ::MinitestLog::VERSION
  end

  def test_new
    exception = assert_raises(MinitestLog::IllegalNewError) do
      MinitestLog.new('foo.xml')
    end
    store_and_assert('new.txt', exception.message)
  end

  def test_open_no_block
    exception = assert_raises(MinitestLog::MinitestLogError) do
      MinitestLog.open
    end
    store_and_assert('open_no_block.txt', exception.message)
  end

  def test_open_block
    _test('open_block') do |_|
    end
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
    _test('open_file_path') do |_|
    end
  end

  def test_open_root_name
    _test('open_root_name', :root_name => 'foo') do |_|
    end
  end

  def test_open_error_verdict
    _test('open_error_verdict', :error_verdict => true) do |_|
    end
  end

  def test_open_xml_indentation
    [-1, 0, 2].each do |indentation|
      _test("open_xml_indentation.#{indentation}", :xml_indentation => indentation) do |log|
        log.section('Section') do
          log.put_data('indentation', indentation)
        end
      end
    end
  end

  def test_open_backtrace_filter
    _test('open_backtrace_filter') do |log|
      Dir.mktmpdir do |dir_path|
        Dir.chdir(dir_path) do
          file_path = nil
          # Default backtrace filter is /log|ruby/.
          MinitestLog.open('./log.xml') do |temp_log|
            file_path = temp_log.file_path
            raise 'Boo!'
          end
          content = File.read(file_path)
          # Default root name is 'log', so 2 of these.
          log.verdict_assert?('default_log', content.scan(/log/).size == 2)
          # All 'ruby' filtered out.
          log.verdict_assert?('default_ruby', content.scan(/ruby/).size == 0)

          MinitestLog.open('./log.xml', :backtrace_filter => /log/) do |temp_log|
            file_path = temp_log.file_path
            raise 'Boo!'
          end
          content = File.read(file_path)
          log.verdict_assert?('log_log', content.scan(/log/).size == 2)
          log.verdict_assert?('log_ruby', content.scan(/ruby/).size > 0)

          MinitestLog.open('./log.xml', :backtrace_filter => /ruby/) do |temp_log|
            file_path = temp_log.file_path
            raise 'Boo!'
          end
          content = File.read(file_path)
          log.verdict_assert?('ruby_log', content.scan(/log/).size > 2)
          log.verdict_assert?('ruby_ruby', content.scan(/ruby/).size == 0)
        end
      end
    end
  end

  def test_nesting
    [:section, :put_element].each do |method|
      name = "#{method}_nesting"
      _test(name) do |log|
        log.send(method, 'no_nesting')
        log.send(method, 'outer') do
          log.send(method, 'inner')
        end
        log.send(method, 'outer') do
          log.send(method, 'mid') do
            log.send(method, 'inner')
          end
        end
      end
    end
  end

  def test_timestamp
    [:section, :put_element].each do |method|
      name = "#{method}_timestamp"
      _test(name) do |log|
        log.send(method, 'no_timestamp') do
        end
        log.send(method, 'timestamp', :timestamp) do
        end
      end
    end
  end

  def test_duration
    [:section, :put_element].each do |method|
      name = "#{method}_duration"
      _test(name) do |log|
        log.send(method, 'no_duration') do
        end
        log.send(method, 'duration', :duration) do
        end
      end
    end
  end

  def test_rescue
    [:section, :put_element].each do |method|
      name = "#{method}_rescue"
      _test(name) do |log|
        log.send(method, 'rescue', :rescue) do
          fail 'Rescued!'
        end
        log.send(method, 'no_rescue') do
          fail 'Not rescued!'
        end
      end
    end
  end

  def test_attributes
    [:section, :put_element].each do |method|
      name = "#{method}_attributes"
      _test(name) do |log|
        log.send(method, 'no_attributes') do
        end
        log.send(method, 'attributes_hash', {:a => 0, :b => 1}) do
        end
        log.send(method, 'attributes_hashes', {:a => 0, :b => 1}, {:c => 2, :d => 3}) do
        end
      end
    end
  end

  def test_element_name
    _test('element_name') do |log|
      log.put_element('section') do
        log.put_element('subsection')
      end
    end
    _test('element_name_illegal') do |log|
      e = assert_raises(MinitestLog::IllegalElementNameError) do
        log.put_element('section_')
      end
      log.put_element('exception', {:class => e.class, :message => e.message})
    end
  end

  def test_pcdata
    [:section, :put_element].each do |method|
      name = "#{method}_pcdata"
      _test(name) do |log|
        log.send(method, 'no_pcdata') do
        end
        log.send(method, 'one_string', 'One') do
        end
        log.send(method, 'two_strings', 'One', 'Two') do
        end
      end
    end
  end

  def test_pot_pourri
    pot_pourri = [
        'one',
        {:a => 0, :b => 1},
        :timestamp,
        :duration,
        {:c => 2, :d => 3},
        'two',
        File,
        'three',
    ]
    [:section, :put_element].each do |method|
      name = "#{method}_pot_pourri"
      _test(name) do |log|
        log.send(method, 'pot_pourri', *pot_pourri)
      end
    end
  end

  def test_inspected
    [:section, :put_element].each do |method|
      name = "#{method}_inspected"
      _test(name) do |log|
        log.send(method, 'no_inspected') do
        end
        log.send(method, 'one_inspected', :one) do
        end
        log.send(method, 'more_inspected', :one, 2, 3.14, (0..2)) do
        end
      end
    end
  end

  def test_put_cdata
    _test('cdata') do |log|
      data = <<EOT

Log
some
multi-line
data.
Include
  leading and trailing spaces.  

EOT
      log.put_cdata(data)
    end

  end

  def test_comment
    _test('comment') do |log|
      log.comment('My comment.')
    end
  end

  def _test_put(method, obj)
    # Test using method.
    _test(method) do |log|
      log.send(method, method.to_s, obj)
    end
    # Test using method :put_data.
    file_name = "#{method}.xml"
    file_path = actual_file_path(file_name)
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
    # Don't allow the logger to recognize as having any of these.
    # This forces the 'else' case, so that the object gets logged via obj#inspect.
    inspect.instance_eval('undef :each_with_index')
    inspect.instance_eval('undef :each')
    inspect.instance_eval('undef :to_s')
    _test_put(:put_inspect, inspect)
  end

  def test_parse
    # Just to make sure we can parse (later).
    file_path = nil
    MinitestLog.open do |log|
      file_path = log.file_path
      log.section('Foo')
    end
    document = MinitestLog.parse(file_path)
    File.delete(file_path)
    assert_equal('log', document.root.name)
  end

end
