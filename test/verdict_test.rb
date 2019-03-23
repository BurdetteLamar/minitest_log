require 'set'

require_relative 'common_requires'

class VerdictTest < MiniTest::Test

  include TestHelper

  def _test_verdict(method:, pass_args: [], fail_args: [], error_args: [])
    {
        :pass => pass_args,
        :fail => fail_args,
        :error => error_args,
    }.each_pair do |type, args|
      name = "#{method.to_s.sub('?', '')}_#{type}"
      file_path = nil
      _test(name) do |log|
        log.section('Test', {:method => method, :type => type}) do
          file_path = File.absolute_path(log.file_path)
          args.each_with_index do |arg, i|
            verdict_id = i.to_s
            if arg.kind_of?(Array)
              args_to_pass = arg
              title = "Args=#{arg.inspect}"
            else
              args_to_pass = [arg]
              title = "Arg: #{arg} (#{arg.class})"
            end
            args_to_pass.push("Message #{i}") unless args_to_pass.empty?
            log.section(title, :rescue) do
              log.send(method, verdict_id, *args_to_pass)
            end
          end
        end
      end
    end
  end

  def test_verdict_assert
     _test_verdict(
        method: :verdict_assert?,
        pass_args: [true, 'not_nil'],
        fail_args: [false, nil],
        error_args: [[], [true, true]]
    )
  end

  def test_verdict_refute
    _test_verdict(
      method: :verdict_refute?,
      pass_args: [false, nil],
      fail_args: [true, :not_nil],
      error_args: [[], [false, false]]
    )
  end

  def zzz_test_verdict_assert_empty
    _test_verdict(
        method: :verdict_refute?,
        pass_args: ['', [], {}],
        fail_args: [true, :not_nil],
        )

    return

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
    _ = children.shift
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
