require 'test_helper'

# noinspection RubyBlockToMethodReference
class MinitestLogTest < Minitest::Test
  def test_version_exist
    refute_nil ::MinitestLog::VERSION
  end

  # Create a temporary logfile.
  # Caller should provide a block to be executed using the log.
  # Returns the file path to the closed log.
  def create_temp_log
    dir_path = Dir.mktmpdir
    file_path = File.join(dir_path, 'log.xml')
    # Suppress all added whitespace, even newline, to facilitate text comparison.
    MinitestLog.open(file_path, {:xml_indentation => -1}) do |log|
      yield log
    end
    file_path
  end

  # Helper class for checking logged output.
  class Checker

    attr_accessor \
      :exceptions,
      :file_path,
      :root,
      :test

    # - +test+:  +MiniTest::Test+ object, to make assertions available.
    # - +file_path+:  Path to log file.
    def initialize(test, file_path)
      # Needs the test object for accessing assertions.
      self.test = test
      self.file_path = file_path
      # Clean up after.
      ObjectSpace.define_finalizer(self, method(:finalize))
      File.open(file_path, 'r') do |file|
        self.root = REXML::Document.new(file).root
      end
      nil
    end

    # To clean up the temporary directory.
    # - +object_id+:  Id of temp directory.
    def finalize(object_id)
      file_path = ObjectSpace._id2ref(object_id).file_path
      File.delete(file_path)
      Dir.delete(File.dirname(file_path))
      nil
    end

    def assert_root_name(name)
      test.assert_equal(name, self.root.name)
    end

    def assert_xml_indentation(indentation)
      File.open(file_path) do |file|
        lines = file.readlines
        case indentation
          when -1
            # Should all be on one line; no whitespace.
            test.assert_equal(1, lines.size)
          when 0
            # Should be multiple lines, but no indentation.
            test.assert_operator(1, :<, lines.size)
            test.refute_match(/^ /, lines[1])
          when 2
            # Should be multiple lines, with 2-space indentation.
            test.assert_operator(1, :<, lines.size)
            test.assert_match(/^ {2}\S/, lines[1])
          else
            raise NotImplementedError(indentation)
        end
      end
    end

    # Verify text in element.
    def assert_element_match(ele_xpath, expected_value)
      actual_value = assert_element_exist(ele_xpath).first.text
      self.test.assert_match(expected_value, actual_value)
    end

    # Verify text in element.
    def assert_element_text(ele_xpath, expected_value)
      actual_value = assert_element_exist(ele_xpath).first.text
      self.test.assert_equal(expected_value, actual_value)
    end

    # Verify attribute match.
    def assert_attribute_match(ele_xpath, attr_name, expected_value)
      attr_xpath = format('%s/@%s', ele_xpath, attr_name)
      actual_value = assert_element_exist(attr_xpath).first.value
      self.test.assert_match(expected_value, actual_value, attr_name)
    end

    # Verify attribute value.
    def assert_attribute_value(ele_xpath, attr_name, expected_value)
      attr_xpath = format('%s/@%s', ele_xpath, attr_name)
      actual_value = assert_element_exist(attr_xpath).first.value
      self.test.assert_equal(expected_value, actual_value, attr_name)
    end

    # Verify attribute values.
    def assert_attribute_values(ele_xpath, attributes)
      attributes.each_pair do |name, value|
        assert_attribute_value(ele_xpath, name, value)
      end
    end

    # Verify element existence.
    def assert_element_exist(ele_xpath)
      elements = match(ele_xpath)
      self.test.assert_operator(elements.size, :>, 0, "No elements at xpath #{ele_xpath}")
      elements
    end

    def assert_cdata_matches(ele_xpath, regexps)
      element = assert_element_exist(ele_xpath).first
      cdatas = element.cdatas
      self.test.assert_equal(1, cdatas.size)
      cdata_value = cdatas.first.value
      regexps.each do |regexp|
        self.test.assert_match(regexp, cdata_value)
        cdata_value.sub!(regexp, '')
      end
      self.test.refute_match(/\S/, cdata_value)
    end

    def assert_counts(ele_xpath, counts)
      element = assert_element_exist(ele_xpath).first
      [
          :attributes,
          :cdatas,
          :comments,
          :texts,
      ].each do |method|
        value = counts[method]
        expected_count = value.nil? ? 0 : value
        actual_count = element.send(method).size
        self.test.assert_equal(expected_count, actual_count, method.to_s)
      end
      method = :get_elements
      value = counts[method]
      expected_count = value.nil? ? 0 : value
      actual_count = element.send(method, ele_xpath).size
      self.test.assert_equal(expected_count, actual_count, method.to_s)
    end

    def match(xpath)
      REXML::XPath.match(root, xpath)
    end

  end

  def args_common_test(log_method, element_name, &block)

    # When log_method is :section we need a block.

    # Hashes.
    h0 = {:a => '0', :b => '1'}
    h1 = {:c => '2', :b => '3'}
    h = h0.merge(h1)
    file_path = create_temp_log do |log|
      log.send(log_method, element_name, h0, h1) do
        block
      end
    end
    checker = Checker.new(self, file_path)
    ele_xpath = "//#{element_name}"
    counts = {
        :attributes => element_name == 'section' ? 4 : 3,
        :get_elements => 1,
    }
    checker.assert_counts(ele_xpath, counts)
    checker.assert_attribute_values(ele_xpath, h)

    # Strings.
    s0 = 'foo'
    s1 = 'bar'
    s = format('%s%s',s0, s1)
    file_path = create_temp_log do |log|
      log.send(log_method, element_name, s0, s1) do
        block
      end
    end
    checker = Checker.new(self, file_path)
    ele_xpath = "//#{element_name}"
    counts = {
        :attributes => element_name == 'section' ? 1 : 0,
        :get_elements => 1,
        :texts => 1,
    }
    checker.assert_counts(ele_xpath, counts)
    checker.assert_element_text(ele_xpath, s)

    # Timestamp.
    file_path = create_temp_log do |log|
      log.send(log_method, element_name, :timestamp) do
        block
      end
    end
    checker = Checker.new(self, file_path)
    ele_xpath = "//#{element_name}"
    counts = {
        :attributes => element_name == 'section' ? 2 : 1,
        :get_elements => 1,
    }
    checker.assert_counts(ele_xpath, counts)
    checker.assert_attribute_match(ele_xpath, :timestamp, /\d{4}-\d{2}-\d{2}-\w{3}-\d{2}\.\d{2}\.\d{2}\.\d{3}/)

    # Duration.
    file_path = create_temp_log do |log|
      log.send(log_method, element_name, :duration) do
        block
      end
    end
    checker = Checker.new(self, file_path)
    ele_xpath = "//#{element_name}"
    counts = {
        :attributes => element_name == 'section' ? 2 : 1,
        :get_elements => 1,
    }
    checker.assert_counts(ele_xpath, counts)
    checker.assert_attribute_match(ele_xpath, :duration_seconds, /\d+\.\d{3}/)

    # Rescue.
    exception_message = 'Wrong'
    file_path = create_temp_log do |log|
      log.send(log_method, element_name, :rescue) do
        raise RuntimeError.new(exception_message)
      end
    end
    checker = Checker.new(self, file_path)
    ele_xpath = "//#{element_name}/rescued_exception"
    counts = {
        :attributes => 2,
        :get_elements => 1,
    }
    checker.assert_counts(ele_xpath, counts)
    attributes = {
        :class => RuntimeError.name,
    }
    checker.assert_attribute_values(ele_xpath, attributes)
    checker.assert_attribute_match(ele_xpath, :timestamp, /\d{4}-\d{2}-\d{2}-\w{3}-\d{2}\.\d{2}\.\d{2}\.\d{3}/)
    ele_xpath = "//#{element_name}/rescued_exception/message"
    checker.assert_element_text(ele_xpath, exception_message)
    ele_xpath = "//#{element_name}/rescued_exception/backtrace"
    checker.assert_element_match(ele_xpath, __method__.to_s)

    # Others.
    [
        0,
        0.0,
        :symbol,
        true,
        Array,
        [0, 1],
    ].each do |other|
      file_path = create_temp_log do |log|
        log.send(log_method, element_name, other) do
          block
        end
      end
      checker = Checker.new(self, file_path)
      ele_xpath = "//#{element_name}"
      counts = {
          :attributes => element_name == 'section' ? 1 : 0,
          :get_elements => 1,
          :texts => 1,
      }
      checker.assert_counts(ele_xpath, counts)
      checker.assert_element_text(ele_xpath, other.inspect)
    end

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
    file_path = './foo.xml'
    MinitestLog.open(file_path) do |log|
      file_path = log.file_path
      log.put_data('file_path', file_path)
    end
    actual = File.read(file_path)
    File.delete(file_path)
    store_and_assert('open_file_path.xml', actual)
  end

  def zzz_test_open_root_name
    root_name = 'foo'
    file_path = MinitestLog.open('foo.xml', :root_name => root_name) do |_|
    end
    checker = Checker.new(self, file_path)
    checker.assert_root_name(root_name)
  end

  def zzz_test_open_xml_indentation
    [-1, 0, 2].each do |indentation|
      file_path = MinitestLog.open('foo.xml', :xml_indentation => indentation) do |log|
        log.section('Section') do
        end
      end
      checker = Checker.new(self, file_path)
      checker.assert_xml_indentation(indentation)
    end

  end

  def zzz_test_section
    method = :section
    # Section names.
    file_path = create_temp_log do |log|
      log.send(method, 'outer') do
        log.send(method, 'inner') do
          log.put_element('tag', 'text')
        end
      end
    end
    checker = Checker.new(self, file_path)
    ele_xpath = "//section[@name='outer']/section[@name='inner']/tag"
    counts = {
        :get_elements => 1,
        :texts => 1,
    }
    checker.assert_counts(ele_xpath, counts)
    checker.assert_element_text(ele_xpath, 'text')
    args_common_test(method, 'section') do
      # Will need a block for calling :section.
    end
  end

  def zzz_test_comment
    method = :comment
    comment = 'My comment'
    file_path = create_temp_log do |log|
      log.send(method, comment)
    end
    checker = Checker.new(self, file_path)
    ele_xpath = '//comment'
    counts = {
        :get_elements => 1,
        :texts => 1,
    }
    checker.assert_counts(ele_xpath, counts)
    checker.assert_element_text(ele_xpath, comment)
  end

  def zzz_test_uncaught_exception
    exception_message = 'Wrong'
    file_path = MinitestLog.open('foo.xml', :xml_indentation => -1) do |_|
      raise RuntimeError.new(exception_message)
    end
    checker = Checker.new(self, file_path)
    ele_xpath = '//uncaught_exception'
    counts = {
        :attributes => 2,
        :get_elements => 1,
    }
    checker.assert_counts(ele_xpath, counts)
    checker.assert_attribute_value(ele_xpath, 'class', RuntimeError.name)
    ele_xpath = '//uncaught_exception/message'
    checker.assert_element_text(ele_xpath, exception_message)
    ele_xpath = '//uncaught_exception/backtrace'
    checker.assert_element_match(ele_xpath, __method__.to_s)
  end

  def zzz_test_put_element
    method = :put_element
    element_name = 'my_element'
    file_path = create_temp_log do |log|
      log.send(method, element_name)
    end
    checker = Checker.new(self, file_path)
    ele_xpath = "//#{element_name}"
    counts = {
        :get_elements => 1,
    }
    checker.assert_counts(ele_xpath, counts)
    checker.assert_element_exist(ele_xpath)
    args_common_test(method, element_name)
  end

  def _test_put_each_with_index(method, arg)
    element_name = 'each_with_index'
    file_path = create_temp_log do |log|
      log.send(method, element_name, arg)
    end
    checker = Checker.new(self, file_path)
    ele_xpath = "//#{element_name}"
    counts = {
        :attributes => 2,
        :cdatas => 1,
        :get_elements => 1,
        :texts => 1,
    }
    checker.assert_counts(ele_xpath, counts)
    regexps = []
    arg.each_with_index do |item, i|
      regexps.push(Regexp.new("#{i} #{item}"))
    end
    checker.assert_cdata_matches(ele_xpath, regexps)
  end

  def zzz_test_put_each_with_index
    method = :put_each_with_index
    arg = [:a, :aa, :aaa]
    _test_put_each_with_index(method, arg)
  end

  def zzz_test_put_array
    method = :put_array
    arg = [:a, :aa, :aaa]
    _test_put_each_with_index(method, arg)
  end

  def zzz_test_put_set
    method = :put_set
    arg = Set.new([:a, :aa, :aaa])
    _test_put_each_with_index(method, arg)
  end

  def _test_put_each_pair(method, arg)
    element_name = 'each_pair'
    file_path = create_temp_log do |log|
      log.send(method, element_name, arg)
    end
    checker = Checker.new(self, file_path)
    ele_xpath = "//#{element_name}"
    counts = {
        :attributes => 2,
        :cdatas => 1,
        :get_elements => 1,
        :texts => 1,
    }
    checker.assert_counts(ele_xpath, counts)
    checker.assert_element_exist(ele_xpath)
  end

  def zzz_test_put_each_pair
    method = :put_each_pair
    arg = {:a => 0, :b => 1}
    _test_put_each_pair(method, arg)
  end

  def zzz_test_put_hash
    method = :put_each_pair
    arg = {:a => 0, :b => 1}
    _test_put_each_pair(method, arg)
  end

  def zzz_test_put_data
    method = :put_data
    element_name = 'data'
    arg = [:a, :aa, :aaa]
    file_path = create_temp_log do |log|
      log.send(method, element_name, arg)
    end
    checker = Checker.new(self, file_path)
    ele_xpath = "//#{element_name}"
    checker.assert_element_exist(ele_xpath)
    arg = {:a => 0, :aa => 1, :aaa => 2}
    file_path = create_temp_log do |log|
      log.send(method, element_name, arg)
    end
    checker = Checker.new(self, file_path)
    ele_xpath = "//#{element_name}"
    counts = {
        :attributes => 2,
        :cdatas => 0,
        :get_elements => 1,
        :texts => 1,
    }
    checker.assert_counts(ele_xpath, counts)
    checker.assert_element_exist(ele_xpath)
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

end
