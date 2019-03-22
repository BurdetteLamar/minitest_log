require 'diff/lcs'
require 'set'

require_relative 'common_requires'

# Class to test class +Log+.
class LogTest < MiniTest::Test

  def test_version_number
    refute_nil ::MinitestLog::VERSION
  end

  # # Caller should provide a block to be executed using the log.
  # # Returns the file path to the closed log.
  # def create_temp_log(test)
  #   dir_path = Dir.mktmpdir
  #   file_path = File.join(dir_path, 'log.xml')
  #   MinitestLog.open({:file_path => file_path}) do |log|
  #     yield log
  #   end
  #   file_path
  # end
  #
  # # Helper class for checking logged output.
  # class Checker
  #
  #   attr_accessor \
  #     :exceptions,
  #     :file_path,
  #     :root,
  #     :test,
  #     :verdicts
  #
  #   # - +test+:  +MiniTest::Test+ object, to make assertions available.
  #   # - +file_path+:  Path to log file.
  #   def initialize(test, file_path)
  #     # Needs the test object for accessing assertions.
  #     self.test = test
  #     self.file_path = file_path
  #     # Clean up after.
  #     ObjectSpace.define_finalizer(self, method(:finalize))
  #     File.open(file_path, 'r') do |file|
  #       self.root = REXML::Document.new(file).root
  #       self.verdicts = {}
  #       REXML::XPath.match(root, '//verdict').each do |verdict|
  #         id = verdict.attributes.get_attribute('id').value.to_sym
  #         self.verdicts.store(id, verdict)
  #       end
  #       self.exceptions = match('//exception')
  #     end
  #     nil
  #   end
  #
  #   # For debugging.
  #   def puts_file
  #     puts File.read(self.file_path)
  #   end
  #
  #   # To clean up the temporary directory.
  #   # - +object_id+:  Id of temp directory.
  #   def finalize(object_id)
  #     file_path = ObjectSpace._id2ref(object_id).file_path
  #     File.delete(file_path)
  #     Dir.delete(File.dirname(file_path))
  #     nil
  #   end
  #
  #   # Verify the verdict count.
  #   def assert_verdict_count(expected_count)
  #     actual_count = self.verdicts.size
  #     self.test.assert_equal(expected_count, actual_count, 'verdict count')
  #   end
  #
  #   # Verify verdict attributes.
  #   def assert_verdict_attributes(verdict_id, expected_attributes)
  #     verdict = verdicts.fetch(verdict_id)
  #     actual_attributes = {}
  #     verdict.attributes.each do |attribute|
  #       name, value = *attribute
  #       actual_attributes[name.to_sym] = value.to_s
  #     end
  #     expected_attributes.each_pair do |name, value|
  #       expected_attributes[name] = value.to_s unless value.kind_of?(Regexp)
  #     end
  #     self.test.assert_equal(Set.new(expected_attributes.keys), Set.new(actual_attributes.keys), 'keys')
  #     expected_attributes.each_pair do |key, expected_value|
  #       actual_value = actual_attributes[key]
  #       self.test.assert_match(expected_value, actual_value, key.to_s)
  #     end
  #     true
  #   end
  #
  #   def assert_exception(expected_message)
  #     expected_assertion_count = expected_message.nil? ? 0 : 1
  #     self.test.assert_equal(expected_assertion_count, self.exceptions.size)
  #     if expected_message
  #       actual_exception_xml = self.exceptions.first.to_s
  #       self.test.assert_match(/Minitest::Assertion/, actual_exception_xml)
  #       expected_message_regexp = Regexp.new(Regexp.quote(expected_message))
  #       self.test.assert_match(expected_message_regexp, actual_exception_xml)
  #     end
  #   end
  #
  #   # Verify text in element.
  #   def assert_element_text(ele_xpath, expected_value)
  #     actual_value = match(ele_xpath).first.text
  #     self.test.assert_match(expected_value, actual_value)
  #   end
  #
  #   # Verify attribute value.
  #   def assert_attribute_value(ele_xpath, attr_name, expected_value)
  #     attr_xpath = format('%s/@%s', ele_xpath, attr_name)
  #     p attr_xpath
  #     actual_value = match(attr_xpath).first.value
  #     self.test.assert_equal(expected_value, actual_value, attr_name)
  #   end
  #
  #   def match(xpath)
  #     REXML::XPath.match(root, xpath)
  #   end
  #
  # end
  #
  # # Tests for (most) all verdict methods.
  # def verdict_common_test(hash)
  #
  #   # Hash arg has these three items.
  #   # The last two values are name/value pairs representing arguments
  #   # that should pass or fail.
  #   method = hash[:method]
  #   passing_arguments = hash[:passing_arguments]
  #   failing_arguments = hash[:failing_arguments]
  #   exception_message = hash[:exception_message]
  #
  #   # Test with passing arguments.
  #   verdict_id = :passes
  #   file_path = create_temp_log(self) do |log|
  #     message = format('Method=%s; verdict_id=%s; data=%s', method, verdict_id, passing_arguments.inspect)
  #     assert(log.send(method, verdict_id, *passing_arguments.values), message)
  #   end
  #   checker = Checker.new(self, file_path)
  #   checker.assert_verdict_count(1)
  #   attributes = {
  #       :id => verdict_id,
  #       :method => method,
  #       :outcome => 'passed',
  #   }
  #   checker.assert_verdict_attributes(verdict_id, attributes)
  #   checker.assert_exception(nil)
  #
  #   # Test with failing arguments.
  #   verdict_id = :fails
  #   file_path = create_temp_log(self) do |log|
  #     message = format('Method=%s; verdict_id=%s; data=s', method, verdict_id, passing_arguments.inspect)
  #     assert(!log.send(method, verdict_id, *failing_arguments.values), message)
  #   end
  #   checker = Checker.new(self, file_path)
  #   checker.assert_verdict_count(1)
  #   attributes = {
  #       :id => verdict_id,
  #       :method => method,
  #       :outcome => 'failed',
  #   }
  #   checker.assert_verdict_attributes(verdict_id, attributes)
  #   exception = Minitest::Assertion.new
  #   checker.assert_exception(exception_message)
  #
  #   # Test with message.
  #   verdict_id = :message
  #   verdict_message = format('Message for method=%s; verdict_id=%s', method, verdict_id)
  #   file_path = create_temp_log(self) do |log|
  #     assert_message = format('Method=%s; verdict_id=%s; data=%s', method, verdict_id, passing_arguments.inspect)
  #     assert(log.send(method, verdict_id, *passing_arguments.values, message: verdict_message), assert_message)
  #   end
  #   checker = Checker.new(self, file_path)
  #   checker.assert_verdict_count(1)
  #   attributes = {
  #       :id => verdict_id,
  #       :method => method,
  #       :outcome => 'passed',
  #       :message => verdict_message,
  #   }
  #   checker.assert_verdict_attributes(verdict_id, attributes)
  #   checker.assert_exception(nil)
  #
  #   nil
  # end

  def test_new
    e = assert_raises(RuntimeError) do
      MinitestLog.new('log.xml')
    end
    File.write('test/actual/new.txt', e.message + "\n")
  end

  def zzz_test_open

    method = :open

    # No block.
    AssertionHelper.assert_raises_with_message(self, RuntimeError, MinitestLog::NO_BLOCK_GIVEN_MSG) do
      MinitestLog.open.send(method)
    end

    # Block.
    dir_path = Dir.mktmpdir
    file_path = File.join(dir_path, 'log.xml')
    AssertionHelper.assert_nothing_raised(self) do
      MinitestLog.open({:file_path => file_path}) do |log|
        log.comment('foo')
      end
    end
    FileUtils.rm_r(dir_path)

  end

  def zzz_test_section

    method = :section

    # Section names.
    file_path = create_temp_log(self) do |log|
      log.send(method, 'outer') do
        log.send(method, 'inner') do
          log.comment('foo')
        end
      end
    end
    checker = Checker.new(self, file_path)
    ele_xpath = "//section[@name='outer']/section[@name='inner']/comment"
    checker.assert_element_text(ele_xpath, 'foo')

    # TODO:  Test *args for section.

  end

  def zzz_test_comment

    comment = 'foo'
    file_path = create_temp_log(self) do |log|
      log.comment(comment)
    end
    checker = Checker.new(self, file_path)
    ele_xpath = "//comment"
    checker.assert_element_text(ele_xpath, comment)

    comment = <<EOT
First line
Second line
Third line
EOT
    file_path = create_temp_log(self) do |log|
      log.comment(comment)
    end
    actual_log = File.read(file_path)
    assert_match(/^First line$/, actual_log)
    assert_match(/^Second line$/, actual_log)
    assert_match(/^Third line$/, actual_log)

  end

  def zzz_test_verdict_assert

    method = :verdict_assert?

    # Use true/false.
    passing_arguments = {
        :actual => true,
    }
    failing_arguments = {
        :actual => false,
    }
    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected false to be truthy.'
    )

    # Use object/nil.
    passing_arguments = {
        :actual => Object.new,
    }
    failing_arguments = {
        :actual => nil,
    }
    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected nil to be truthy.'
    )

  end

  def zzz_test_verdict_refute

    method = :verdict_refute?

    # Use false/true.
    passing_arguments = {
        :actual => false,
    }
    failing_arguments = {
        :actual => true,
    }
    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected true to not be truthy.'
    )

    # Use nil/1.
    passing_arguments = {
        :actual => nil,
    }
    failing_arguments = {
        :actual => 1,
    }
    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected 1 to not be truthy.'
    )

  end

  def zzz_test_verdict_assert_empty

    method = :verdict_assert_empty?
    passing_arguments = {
        :actual => [],
    }
    failing_arguments = {
        :actual => [1],
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected [1] to be empty.'
    )

    verdict_id = :no_empty_method_fails
    file_path = create_temp_log(self) do |log|
      verdict = log.send(method, verdict_id, 0)
      assert(!verdict, verdict_id)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'failed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_exception('Expected 0 (Fixnum) to respond to #empty?.')

  end

  def zzz_test_verdict_refute_empty

    method = :verdict_refute_empty?
    passing_arguments = {
        :actual => [1],
    }
    failing_arguments = {
        :actual => [],
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected [] to not be empty.'
    )

    verdict_id = :no_empty_method_fails
    file_path = create_temp_log(self) do |log|
      verdict = log.send(method, verdict_id, 0)
      assert(!verdict, verdict_id)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'failed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_exception('Expected 0 (Fixnum) to respond to #empty?.')

  end

  def zzz_test_verdict_assert_equal

    method = :verdict_assert_equal?
    passing_arguments = {
        :expected => 0,
        :actual => 0,
    }
    failing_arguments = {
        :expected => 0,
        :actual => 1,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected: 0 Actual: 1'
    )

    verdict_id = :array_passes
    file_path = create_temp_log(self) do |log|
      array = [:a, :b, :c]
      assert(log.send(method, verdict_id, array, array), verdict_id)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'passed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_exception(nil)

    verdict_id = :hash_passes
    file_path = create_temp_log(self) do |log|
      assert(log.send(method, verdict_id, {:a => 0}, {:a => 0}), verdict_id)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'passed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_exception(nil)

    verdict_id = :set_passes
    file_path = create_temp_log(self) do |log|
      assert(log.send(method, verdict_id, Set.new([:a, :b]), Set.new([:b, :a])), verdict_id)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {

        :id => verdict_id,
        :method => method,
        :outcome => 'passed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_exception(nil)

    verdict_id = :array_fails
    file_path = create_temp_log(self) do |log|
      expected = [:a, :b, :c, :d, :e, :f, :k, :l, :m, :n]
      actual = [:a, :b, :g, :h, :c, :d, :i, :j, :k, :l]
      assert(!log.send(method, verdict_id, expected, actual), verdict_id)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'failed',
    }
    # checker.puts_file
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_verdict_count(1)
    analysis = checker.match('//analysis').first
    expected_attributes = {
        'expected_class' => 'Array',
        'actual_class' => 'Array',
        'methods' => '[:each_pair]',
    }
    analysis.attributes.each_pair do |_, actual_attribute|
      expected_value = expected_attributes.delete(actual_attribute.name)
      assert_equal(expected_value, actual_attribute.value)
    end
    assert_empty(expected_attributes)
    children = analysis.children
    child = children.shift
    child = children.shift
    p child
    # <unchanged>
    # <old>pos=0 ele=a</old>
    #     <new>pos=0 ele=a</new>
    # </unchanged>

    # checker.assert_attribute_value("//analysis/unchanged/old[@pos='0']", 'ele', 'a')
    # checker.assert_attribute_value('//analysis/unexpected', 'b', '1')
    # checker.assert_attribute_value('//analysis/changed', 'c', '{:expected=>2, :actual=>3}')
    # checker.assert_attribute_value('//analysis/ok', 'd', '3')

    verdict_id = :hash_fails
    file_path = create_temp_log(self) do |log|
      assert(!log.send(method, verdict_id,
                       {:a => 0, :c => 2, :d => 3},
                       {:b => 1, :c => 3, :d => 3},
      ), verdict_id)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'failed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_verdict_count(1)
    checker.assert_attribute_value('//analysis/missing', 'a', '0')
    checker.assert_attribute_value('//analysis/unexpected', 'b', '1')
    checker.assert_attribute_value('//analysis/changed', 'c', '{:expected=>2, :actual=>3}')
    checker.assert_attribute_value('//analysis/ok', 'd', '3')

    verdict_id = :set_fails
    file_path = create_temp_log(self) do |log|
      assert(!log.send(method, verdict_id,
                       Set.new([:a, :b]),
                       Set.new([:a, :c]),
             ), verdict_id)
    end
    checker = Checker.new(self, file_path)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'failed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_verdict_count(1)
    checker.assert_element_text('//analysis/missing', Set.new([:b]).inspect)
    checker.assert_element_text('//analysis/unexpected', Set.new([:c]).inspect)
    checker.assert_element_text('//analysis/ok', Set.new([:a]).inspect)

    verdict_id = :different_types
    file_path = create_temp_log(self) do |log|
      assert(!log.send(method, verdict_id, 0, 'a'), verdict_id)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'failed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_exception('--- expected +++ actual @@ -1 +1,2 @@ -0 +# encoding: UTF-8 +&quot;a&quot;')

  end

  def zzz_test_verdict_refute_equal

    method = :verdict_refute_equal?
    passing_arguments = {
        :expected => 0,
        :actual => 1,
    }
    failing_arguments = {
        :expected => 0,
        :actual => 0,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected 0 to not be equal to 0.'
    )

  end

  def zzz_test_verdict_assert_in_delta

    method = :verdict_assert_in_delta?
    passing_arguments = {
        :expected => 0,
        :actual => 1,
        :delta => 1,
    }
    failing_arguments = {
        :expected => 0,
        :actual => 1,
        :delta => 0.1,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected |0 - 1| (1) to be &lt;= 0.1.'
    )

  end

  def zzz_test_verdict_refute_in_delta

    method = :verdict_refute_in_delta?
    passing_arguments = {
        :expected => 0,
        :actual => 1,
        :delta => 0.11,
    }
    failing_arguments = {
        :expected => 0,
        :actual => 1,
        :delta => 1,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected |0 - 1| (1) to not be &lt;= 1.',
    )

  end

  def zzz_test_verdict_assert_in_epsilon

    method = :verdict_assert_in_epsilon?
    passing_arguments = {
        :expected => 0,
        :actual => 0,
        :delta => 1,
    }
    failing_arguments = {
        :expected => 0,
        :actual => 4,
        :delta => 1,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected |0 - 4| (4) to be &lt;= 0.'
    )

  end

  def zzz_test_verdict_refute_in_epsilon

    method = :verdict_refute_in_epsilon?
    passing_arguments = {
        :expected => 0,
        :actual => 1,
        :delta => 0.1,
    }
    failing_arguments = {
        :expected => 0,
        :actual => 0,
        :delta => 1,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected |0 - 0| (0) to not be &lt;= 0.'
    )

  end

  def zzz_test_verdict_assert_includes

    method = :verdict_assert_includes?
    passing_arguments = {
        :expected => [0],
        :actual => 0,
    }
    failing_arguments = {
        :expected => [0],
        :actual => 1,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected [0] to include 1.'
    )

  end

  def zzz_test_verdict_refute_includes

    method = :verdict_refute_includes?
    passing_arguments = {
        :expected => [0],
        :actual => 1,
    }
    failing_arguments = {
        :expected => [0],
        :actual => 0,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected [0] to not include 0.'
    )

  end

  def zzz_test_verdict_assert_instance_of

    method = :verdict_assert_instance_of?
    passing_arguments = {
        :expected => String,
        :actual => '',
    }
    failing_arguments = {
        :expected => String,
        :actual => 0,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected 0 to be an instance of String, not Fixnum.'
    )

  end

  def zzz_test_verdict_refute_instance_of

    method = :verdict_refute_instance_of?
    passing_arguments = {
        :expected => String,
        :actual => 0,
    }
    failing_arguments = {
        :expected => String,
        :actual => '',
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected # encoding: UTF-8 &quot;&quot; to not be an instance of String.'
    )

  end

  def zzz_test_verdict_assert_kind_of

    method = :verdict_assert_kind_of?
    passing_arguments = {
        :expected => Object,
        :actual => String,
    }
    failing_arguments = {
        :expected => String,
        :actual => 0,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected 0 to be a kind of String, not Fixnum.'
    )

  end

  def zzz_test_verdict_refute_kind_of

    method = :verdict_refute_kind_of?
    passing_arguments = {
        :expected => String,
        :actual => 0,
    }
    failing_arguments = {
        :expected => Object,
        :actual => String,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected String to not be a kind of Object.'
    )

  end

  def zzz_test_verdict_assert_match

    method = :verdict_assert_match?
    passing_arguments = {
        :expected => %r/x/,
        :actual => 'x',
    }
    failing_arguments = {
        :expected => %r/x/,
        :actual => 'y',
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected /x/ to match # encoding: UTF-8 &quot;y&quot;.'
    )

  end

  def zzz_test_verdict_refute_match

    method = :verdict_refute_match?
    passing_arguments = {
        :expected => %r/x/,
        :actual => 'y',
    }
    failing_arguments = {
        :expected => %r/x/,
        :actual => 'x',
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected /x/ to not match # encoding: UTF-8 &quot;x&quot;.'
    )

  end

  def zzz_test_verdict_assert_nil

    method = :verdict_assert_nil?
    passing_arguments = {
        :actual => nil,
    }
    failing_arguments = {
        :actual => true,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected true to be nil.'
    )

  end

  def zzz_test_verdict_refute_nil

    method = :verdict_refute_nil?
    passing_arguments = {
        :actual => true,
    }
    failing_arguments = {
        :actual => nil,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected nil to not be nil.'
    )

  end

  def zzz_test_verdict_assert_operator

    method = :verdict_assert_operator?
    passing_arguments = {
        :object_0 => 1,
        :operator => :<,
        :object_1 => 2,
    }
    failing_arguments = {
        :object_0 => 1,
        :operator => :>,
        :object_1 => 2,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected 1 to be &gt; 2.'
    )

  end

  def zzz_test_verdict_refute_operator

    method = :verdict_refute_operator?
    passing_arguments = {
        :object_0 => 1,
        :operator => :>,
        :object_1 => 2,
    }
    failing_arguments = {
        :object_0 => 1,
        :operator => :<,
        :object_1 => 2,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected 1 to not be &lt; 2.'
    )

  end

  def zzz_test_verdict_output

    method = :verdict_assert_output?
    passing_arguments = {
        :stdout => 'stdout',
        :stderr => 'stderr',
    }
    failing_arguments = {
        :stdout => 'not stdout',
        :stderr => 'not stderr',
    }
    # Test with passing arguments.
    verdict_id = :passes
    file_path = create_temp_log(self) do |log|
      message = format('Method=%s; verdict_id=%s; data=%s', method, verdict_id, passing_arguments.inspect)
      verdict = log.send(method, verdict_id, *passing_arguments.values) do
        $stdout.print(passing_arguments[:stdout])
        $stderr.print(passing_arguments[:stderr])
      end
      assert(verdict, message)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'passed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_exception(nil)
    # Test with failing arguments.
    verdict_id = :fails
    file_path = create_temp_log(self) do |log|
      message = format('Method=%s; verdict_id=%s; data=%s', method, verdict_id, passing_arguments.inspect)
      verdict = log.send(method, verdict_id, *passing_arguments.values) do
        $stdout.print(failing_arguments[:stdout])
        $stderr.print(failing_arguments[:stderr])
      end
      assert(!verdict, message)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'failed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_exception('not stderr')

  end

  # Minitest::Assertion does not have :refute_output, so we don't have :verdict_refute_output?.

  def zzz_test_verdict_assert_predicate

    method = :verdict_assert_predicate?
    passing_arguments = {
        :object => '',
        :predicate => :empty?
    }
    failing_arguments = {
        :object => 'foo',
        :predicate => :empty?
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected # encoding: UTF-8 &quot;foo&quot; to be empty?.'
    )

  end

  def zzz_test_verdict_refute_predicate

    method = :verdict_refute_predicate?
    passing_arguments = {
        :object => 'foo',
        :predicate => :empty?
    }
    failing_arguments = {
        :object => '',
        :predicate => :empty?
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected # encoding: UTF-8 &quot;&quot; to not be empty?.'
    )

  end

  def zzz_test_verdict_raises

    method = :verdict_assert_raises?
    passing_arguments = {
        :passes => RuntimeError,
    }
    failing_arguments = {
        :fails => NotImplementedError
    }
    # Test with passing arguments.
    verdict_id = :passes
    file_path = create_temp_log(self) do |log|
      message = format('Method=%s; verdict_id=%s; data=%s', method, verdict_id, passing_arguments.inspect)
      verdict = log.send(method, verdict_id, *passing_arguments.values) do
        raise passing_arguments[:passes].new('Boo!')
      end
      assert(verdict, message)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'passed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_exception(nil)
    # Test with failing arguments.
    verdict_id = :fails
    file_path = create_temp_log(self) do |log|
      message = format('Method=%s; verdict_id=%s; data=%s', method, verdict_id, passing_arguments.inspect)
      verdict = log.send(method, verdict_id, *passing_arguments.values) do
        raise failing_arguments[:fails].new('Boo!')
      end
      assert(!verdict, message)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'failed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_exception('[RuntimeError] exception expected')

  end

  # Minitest::Assertion does not have :refute_raises, so we don't have :verdict_refute_raises?.

  def zzz_test_verdict_assert_respond_to

    method = :verdict_assert_respond_to?
    passing_arguments = {
        :object => '',
        :method => :empty?
    }
    failing_arguments = {
        :object => 0,
        :method => :empty?
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected 0 (Fixnum) to respond to #empty?.'
    )

  end

  def zzz_test_verdict_refute_respond_to

    method = :verdict_refute_respond_to?
    passing_arguments = {
        :object => 0,
        :method => :empty?
    }
    failing_arguments = {
        :object => '',
        :method => :empty?
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected # encoding: UTF-8 &quot;&quot; to not respond to empty?.'
    )

  end

  def zzz_test_verdict_assert_same

    method = :verdict_assert_same?
    passing_arguments = {
        :expected => :same,
        :actual => :same,
    }
    failing_arguments = {
        :expected => :same,
        :actual => :different,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected :different'
    )

  end

  def zzz_test_verdict_refute_same

    method = :verdict_refute_same?
    passing_arguments = {
        :expected => :same,
        :actual => :different,
    }
    failing_arguments = {
        :expected => :same,
        :actual => :same,
    }

    verdict_common_test(
        :method => method,
        :passing_arguments => passing_arguments,
        :failing_arguments => failing_arguments,
        :exception_message => 'Expected :same'
    )

  end

  # Minitest::Assertion treats method :assert_send as deprecated, so we don't have :verdict_assert_send.

  # Minitest::Assertion does not have :refute_send, so we don't have :verdict_refute_send?.

  def zzz_test_verdict_silent

    method = :verdict_assert_silent?
    # Test with passing arguments.
    verdict_id = :passes
    file_path = create_temp_log(self) do |log|
      message = format('Method=%s; verdict_id=%s', method, verdict_id)
      verdict = log.send(method, verdict_id) do
      end
      assert(verdict, message)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'passed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_exception(nil)
    # Test with failing arguments.
    verdict_id = :fails
    file_path = create_temp_log(self) do |log|
      message = format('Method=%s; verdict_id=%s', method, verdict_id)
      verdict = log.send(method, verdict_id) do
        $stdout.print('Boo!')
        $stderr.print('Boo!')
      end
      assert(!verdict, message)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'failed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_exception('&quot;&quot; +&quot;Boo!&quot;')

  end

  # Minitest::Assertion does not have :refute_silent, so we don't have :verdict_refute_silent?.

  def zzz_test_verdict_throws

    method = :verdict_assert_throws?
    passing_arguments = {
        :passes => Exception,
    }
    failing_arguments = {
        :fails => NotImplementedError
    }
    # Test with passing arguments.
    verdict_id = :passes
    file_path = create_temp_log(self) do |log|
      message = format('Method=%s; verdict_id=%s; data=%s', method, verdict_id, passing_arguments.inspect)
      verdict = log.send(method, verdict_id, *passing_arguments.values) do
        throw passing_arguments[:passes]
      end
      assert(verdict, message)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'passed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_exception(nil)
    # Test with failing arguments.
    verdict_id = :fails
    file_path = create_temp_log(self) do |log|
      message = format('Method=%s; verdict_id=%s; data=%s', method, verdict_id, passing_arguments.inspect)
      verdict = log.send(method, verdict_id, *passing_arguments.values) do
        throw failing_arguments[:fails]
      end
      assert(!verdict, message)
    end
    checker = Checker.new(self, file_path)
    checker.assert_verdict_count(1)
    attributes = {
        :id => verdict_id,
        :method => method,
        :outcome => 'failed',
    }
    checker.assert_verdict_attributes(verdict_id, attributes)
    checker.assert_exception('Expected Exception to have been thrown')

  end

end
