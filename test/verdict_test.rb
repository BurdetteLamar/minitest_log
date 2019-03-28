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
  
  def with_verdict_test_log(name, options = {})
    verdict_options = options.merge(
                               :error_verdict => true,
                               :summary => true,
    )
    with_test_log(name, verdict_options) do |log|
      yield log
    end
  end

  def methods_for_test(test_method)
    method_s = "#{test_method.to_s.sub('test_', '')}?"
    abbrev_s = method_s.sub('verdict_', 'v').sub('assert', 'a').sub('refute', 'r')
    [method_s.to_sym, abbrev_s.to_sym]
  end

  def _test_name(method, type)
    "#{method.to_s.sub('?', '')}_#{type}"
  end

  def _test_verdict(test_method:, arg_count_range:, pass_cases: [], fail_cases: [])
    method, abbrev_method = methods_for_test(test_method)
    error_cases = [
        # Too few arguments.
        Args.new,
        # Too many arguments.
        Args.new(*Array.new(arg_count_range.max + 1))
    ]
    {
        :pass => pass_cases,
        :fail => fail_cases,
        :error => error_cases,
    }.each_pair do |type, cases|
      name = _test_name(method, type)
      # Test with both full and abbrev method names.
      # But there will be only one log file, written twice.
      [method, abbrev_method].each do |_method|
        with_verdict_test_log(name) do |log|
          log.section('Test', {:method => method, :type => type}) do
            cases.each_with_index do |_case, i|
              # Be careful to not disturb case.args;  we're in a loop.
              args = _case.args.clone
              # Add message, unless it would make a too-short arg list long enough after all.
              unless args.size < arg_count_range.min
                args.push("Message #{i}")
              end
              title = "Args=#{args}"
              verdict_id = i.to_s
              log.section(title, :rescue) do
                log.send(_method, verdict_id, *args)
              end
            end
          end
        end
      end
    end
  end

  def test_verdict_assert
     _test_verdict(
        test_method: __method__,
        arg_count_range: (1..1),
        pass_cases: [Args.new(true), Args.new('not_nil')],
        fail_cases: [Args.new(false), Args.new(nil)],
    )
  end

  def test_verdict_refute
    _test_verdict(
      test_method: __method__,
      arg_count_range: (1..1),
      pass_cases: [Args.new(false), Args.new(nil)],
      fail_cases: [Args.new(true), Args.new('not_nil')],
    )
  end

  def test_verdict_assert_empty
    _test_verdict(
        test_method: __method__,
        arg_count_range: (1..1),
        pass_cases: [Args.new([]), Args.new('')],
        fail_cases: [Args.new([0]), Args.new('not_empty')],
    )
  end

  def test_verdict_refute_empty
    _test_verdict(
        test_method: __method__,
        arg_count_range: (1..1),
        pass_cases: [Args.new([0]), Args.new('not_empty')],
        fail_cases: [Args.new([]), Args.new('')],
    )
  end

  def test_verdict_assert_equal
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [Args.new(0, 0), Args.new(:a, :a)],
        fail_cases: [Args.new(0, 1), Args.new(:a, :b)],
    )
  end

  def test_verdict_refute_equal
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [Args.new(0, 1), Args.new(:a, :b)],
        fail_cases: [Args.new(0, 0), Args.new(:a, :a)],
    )
  end

  def test_verdict_assert_in_delta
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..3),
        pass_cases: [Args.new(0, 0, 1), Args.new(1, 1, 1)],
        fail_cases: [Args.new(0, 2, 1), Args.new(2, 0, 1)],
        )
  end

  def test_verdict_refute_in_delta
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..3),
        fail_cases: [Args.new(0, 0, 1), Args.new(1, 1, 1)],
        pass_cases: [Args.new(0, 2, 1), Args.new(2, 0, 1)],
        )
  end

  def test_verdict_assert_in_epsilon
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..3),
        pass_cases: [Args.new(3, 2, 1), Args.new(4, 3, 1)],
        fail_cases: [Args.new(3, 2, 0), Args.new(4, 3, 0)],
        )
  end

  def test_verdict_refute_in_epsilon
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..3),
        pass_cases: [Args.new(3, 2, 0), Args.new(4, 3, 0)],
        fail_cases: [Args.new(3, 2, 1), Args.new(4, 3, 1)],
        )
  end

  def test_verdict_assert_includes
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [Args.new([0], 0), Args.new([:a], :a)],
        fail_cases: [Args.new([0], 1), Args.new([:a], :b)],
        )
  end

  def test_verdict_refute_includes
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [Args.new([0], 1), Args.new([:a], :b)],
        fail_cases: [Args.new([0], 0), Args.new([:a], :a)],
        )
  end

  def test_verdict_assert_instance_of
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [Args.new(Integer, 0), Args.new(Symbol, :a)],
        fail_cases: [Args.new(Integer, :a), Args.new(Symbol, 0)],
        )
  end

  def test_verdict_refute_instance_of
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [Args.new(Integer, :a), Args.new(Symbol, 0)],
        fail_cases: [Args.new(Integer, 0), Args.new(Symbol, :a)],
        )
  end

  def test_verdict_assert_kind_of
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [
            Args.new(Exception, ArgumentError.new),
            Args.new(Numeric, 0),
        ],
        fail_cases: [
            Args.new(Array, {}),
            Args.new(Hash, [])
        ],
        )
  end

  def test_verdict_refute_kind_of
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [
            Args.new(Array, {}),
            Args.new(Hash, [])
        ],
        fail_cases: [
            Args.new(Exception, ArgumentError.new),
            Args.new(Numeric, 0),
        ],
        )
  end

  def test_verdict_assert_match
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [Args.new(/b/, 'abc'), Args.new(/./, 'a')],
        fail_cases: [Args.new(/b/, 'xyz'), Args.new(/./, '')],
        )
  end

  def test_verdict_refute_match
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [Args.new(/b/, 'xyz'), Args.new(/./, '')],
        fail_cases: [Args.new(/b/, 'abc'), Args.new(/./, 'a')],
        )
  end

  def test_verdict_assert_nil
    x = nil
    _test_verdict(
        test_method: __method__,
        arg_count_range: (1..1),
        pass_cases: [Args.new(nil), Args.new(x)],
        fail_cases: [Args.new(0), Args.new(false)],
        )
  end

  def test_verdict_refute_nil
    x = nil
    _test_verdict(
        test_method: __method__,
        arg_count_range: (1..1),
        pass_cases: [Args.new(0), Args.new(false)],
        fail_cases: [Args.new(nil), Args.new(x)],
        )
  end

  def test_verdict_assert_operator
    _test_verdict(
        test_method: __method__,
        arg_count_range: (3..3),
        pass_cases: [Args.new(0, :<, 1), Args.new(true, :==, true)],
        fail_cases: [Args.new(0, :==, 1), Args.new(false, :==, true)],
        )
  end

  def test_verdict_refute_operator
    _test_verdict(
        test_method: __method__,
        arg_count_range: (3..3),
        pass_cases: [Args.new(0, :==, 1), Args.new(false, :==, true)],
        fail_cases: [Args.new(0, :<, 1), Args.new(true, :==, true)],
        )
  end

  def test_verdict_assert_output
    method, abbrev_method = methods_for_test(__method__)
    [method, abbrev_method].each do |_method|
      name = _test_name(method, 'pass')
      with_verdict_test_log(name) do |log|
        log.send(_method, '0', 'foo', 'bar') do
          $stdout.write 'foo'
          $stderr.write 'bar'
        end
      end
      name = _test_name(method, 'fail')
      with_verdict_test_log(name) do |log|
        log.send(_method, '1', 'foo', 'bar') do
          $stdout.write 'bar'
          $stderr.write 'foo'
        end
      end
      name = _test_name(method, 'error')
      with_verdict_test_log(name) do |log|
        log.send(_method, '2', 'foo')
      end
    end
  end

  # Minitest::Assertion does not have :refute_output, so we don't have :verdict_refute_output?.

  def test_verdict_assert_predicate
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [Args.new('', :empty?), Args.new(nil, :nil?)],
        fail_cases: [Args.new('x', :empty?), Args.new(false, :nil?)],
        )
  end

  def test_verdict_refute_predicate
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [Args.new('x', :empty?), Args.new(false, :nil?)],
        fail_cases: [Args.new('', :empty?), Args.new(nil, :nil?)],
        )
  end

  def test_verdict_assert_raises
    method, abbrev_method = methods_for_test(__method__)
    [method, abbrev_method].each do |_method|
    name = _test_name(method, 'pass')
    with_verdict_test_log(name) do |log|
      log.send(_method, '0', RuntimeError) do
        raise RuntimeError.new('Boo!')
      end
    end
    name = _test_name(method, 'fail')
    with_verdict_test_log(name) do |log|
      log.send(_method, '1', RuntimeError) do
      end
    end
    name = _test_name(method, 'error')
    with_verdict_test_log(name) do |log|
      log.send(_method, '2')
    end
    end

  end

  # Minitest::Assertion does not have :refute_raises, so we don't have :verdict_refute_raises?.

  def test_verdict_assert_respond_to
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [Args.new('', :size), Args.new(nil, :class)],
        fail_cases: [Args.new('', :foo), Args.new(false, :bar)],
        )
  end

  def test_verdict_refute_respond_to
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [Args.new('', :foo), Args.new(false, :bar)],
        fail_cases: [Args.new('', :size), Args.new(nil, :class)],
        )
  end

  def test_verdict_assert_same
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [Args.new(:foo, :foo), Args.new(0, 0)],
        fail_cases: [Args.new('foo', 'foo'), Args.new([], [])],
        )
  end

  def test_verdict_refute_same
    _test_verdict(
        test_method: __method__,
        arg_count_range: (2..2),
        pass_cases: [Args.new('foo', 'foo'), Args.new([], [])],
        fail_cases: [Args.new(:foo, :foo), Args.new(0, 0)],
        )
  end

  # Minitest::Assertion treats method :assert_send as deprecated, so we don't have :verdict_assert_send.

  # Minitest::Assertion does not have :refute_send, so we don't have :verdict_refute_send?.

  def test_verdict_assert_silent
    method, abbrev_method = methods_for_test(__method__)
    [method, abbrev_method].each do |_method|
      name = _test_name(method, 'pass')
      with_verdict_test_log(name) do |log|
        log.send(_method, '0') do
        end
      end
      name = _test_name(method, 'fail')
      with_verdict_test_log(name) do |log|
        log.send(_method, '1') do
          $stdout.write 'bar'
          $stderr.write 'foo'
        end
      end
      name = _test_name(method, 'error')
      with_verdict_test_log(name) do |log|
        log.send(_method, '2', 'message', 'extra') do
        end
      end
    end
  end

  # Minitest::Assertion does not have :refute_silent, so we don't have :verdict_refute_silent?.

  def test_verdict_assert_throws
    method, abbrev_method = methods_for_test(__method__)
    [method, abbrev_method].each do |_method|
    name = _test_name(method, 'pass')
    with_verdict_test_log(name) do |log|
      log.send(_method, '0', Exception) do
        throw Exception
      end
    end
    name = _test_name(method, 'fail')
    with_verdict_test_log(name) do |log|
      log.send(_method, '1', RuntimeError) do
      end
    end
    name = _test_name(method, 'error')
    with_verdict_test_log(name) do |log|
      log.send(_method, '2')
    end
      end
  end

end
