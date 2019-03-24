require 'set'

require_relative 'common_requires'

class VerdictTest < MiniTest::Test

  include TestHelper

  class Args
    attr_accessor :args
    def initialize(*args)
      self.args = args
    end
  end
  
  def _test_verdict(method:, arg_count_range:, pass_cases: [], fail_cases: [], error_cases: [])
    {
        :pass => pass_cases,
        :fail => fail_cases,
        :error => error_cases,
    }.each_pair do |type, cases|
      name = "#{method.to_s.sub('?', '')}_#{type}"
      file_path = nil
      _test(name) do |log|
        log.section('Test', {:method => method, :type => type}) do
          file_path = File.absolute_path(log.file_path)
          cases.each_with_index do |_case, i|
            verdict_id = i.to_s
            args = _case.args
            title = "Args=#{args}"
            unless args.size < arg_count_range.min
              args.push("Message #{i}")
            end
            log.section(title, :rescue) do
              log.send(method, verdict_id, *args)
            end
          end
        end
      end
    end
  end

  def test_verdict_assert
     _test_verdict(
        method: :verdict_assert?,
        arg_count_range: (1..1),
        pass_cases: [Args.new(true), Args.new('not_nil')],
        fail_cases: [Args.new(false), Args.new(nil)],
        error_cases: [Args.new(), Args.new(nil, nil)]
        # pass_cases: Cases.new(true, 'not_nil'),
        # fail_cases: Cases.new(false, nil),
        # error_cases: Cases.new([], [true, true])
    )
  end

  def zzz_test_verdict_refute
    _test_verdict(
      method: :verdict_refute?,
      pass_cases: [false, nil],
      fail_cases: [true, :not_nil],
      error_cases: [[], [false, false]]
    )
  end

  def zzz_test_verdict_assert_empty
    _test_verdict(
        method: :verdict_assert_empty?,
        pass_cases: ['', {}],
        fail_cases: ['not empty', {:a => 0}],
        error_cases: [[], [false, false]]
    )
  end

  def zzz_test_verdict_refute_empty
    _test_verdict(
        method: :verdict_refute_empty?,
        pass_cases: ['not empty', {:a => 0}],
        fail_cases: ['', {}],
        error_cases: [[], [false, false]]
    )
  end

  def zzz_test_verdict_assert_equal
    _test_verdict(
        method: :verdict_assert_equal?,
        pass_cases: [[0, 0], [:a, :a]],
        fail_cases: [[0, 1], [:a, :b]],
        error_cases: [[], [0, 0, 0]]
    )
  end

  def zzz_test_verdict_refute_equal
    _test_verdict(
        method: :verdict_refute_equal?,
        pass_cases: [[0, 1], [:a, :b]],
        fail_cases: [[0, 0], [:a, :a]],
        error_cases: [[], [0, 0, 0]]
    )
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
