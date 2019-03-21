require 'rexml/document'
require 'minitest/autorun'
require 'minitest/assertions'
require 'nokogiri'

require 'diff/lcs'

require_relative 'helpers/array_helper'
require_relative 'helpers/hash_helper'
require_relative 'helpers/set_helper'

# When adding a module here, be sure to 'include' below.
require_relative 'verdict_assertion'

## Class to support XML logging.
#
# === About *args
# Method section and all verdict methods pass a final argument *+args+
# whose content is eventually passed to method put_element.
# See how that content is handled by viewing the documentation at put_element.
#
# === About Aliases
# For clarity, the verdict methods that correspond to methods in Minitest::Assertions
# have longish names that clearly indicate the correspondence.
# Method verdict_assert_in_delta?, for example,
# corresponds to assertion method assert_in_delta.
#
# To aid both the test developer and the IDE's code-completion efforts,
# each such method has a shorter alias.
# Thus method verdict_assert_in_delta? has alias va_in_delta?,
# and method verdict_refute_in_delta? has alias vr_in_delta?.
class MinitestLog

  include VerdictAssertion

  attr_accessor \
    :assertions,
    :counts,
    :file,
    :file_path,
    :backtrace_filter,
    :root_name,
    :verdict_ids,
    :xml_indentation

  include REXML
  include Minitest::Assertions

  DEFAULT_FILE_NAME = 'log.xml'
  DEFAULT_DIR_PATH = '.'
  DEFAULT_XML_ROOT_TAG_NAME = 'log'
  DEFAULT_XML_INDENTATION = 2

  def self.open(file_path = File.join(DEFAULT_DIR_PATH, DEFAULT_FILE_NAME), options=Hash.new)
    raise "No block given.\n" unless (block_given?)
    default_options = Hash[
        :root_name => DEFAULT_XML_ROOT_TAG_NAME,
        :xml_indentation => DEFAULT_XML_INDENTATION
    ]
    options = default_options.merge(options)
    log = self.new(file_path, options, im_ok_youre_not_ok = true)
    begin
      yield log
    rescue => x
      log.put_element('uncaught_exception', :timestamp, :class => x.class) do
        log.put_element('message', x.message)
        log.put_element('backtrace') do
          backtrace = log.send(:filter_backtrace, x.backtrace)
          log.put_cdata(backtrace.join("\n"))
        end
      end
    end
    log.send(:dispose)
    nil
  end

  def put_cdata(text)
    # Guard against using a terminator that's a substring of the cdata.
    s = 'EOT'
    terminator = s
    while text.match(terminator) do
      terminator += s
    end
    log_puts("CDATA\t<<#{terminator}")
    log_puts(text)
    log_puts(terminator)
    nil
  end

  def section(name, *args)
    put_element('section', {:name => name}, *args) do
      yield
    end
    nil
  end

  def comment(text, *args)
    if text.match("\n")
      # Separate text from containing punctuation.
      put_element('comment') do
        cdata("\n#{text}\n")
      end
    else
      put_element('comment', text, *args)
    end
    nil
  end

  def put_element(element_name = 'element', *args)
    attributes = {}
    pcdata = ''
    start_time = nil
    duration_to_be_included = false
    block_to_be_rescued = false
    args.each do |arg|
      case
      when arg.kind_of?(Hash)
        attributes.merge!(arg)
      when arg.kind_of?(String)
        pcdata += arg
      when arg == :timestamp
        attributes[:timestamp] = MinitestLog.timestamp
      when arg == :duration
        duration_to_be_included = true
      when arg == :rescue
        block_to_be_rescued = true
      else
        pcdata = pcdata + arg.inspect
      end
    end
    log_puts("BEGIN\t#{element_name}")
    put_attributes(attributes)
    unless pcdata.empty?
      # Guard against using a terminator that's a substring of pcdata.
      s = 'EOT'
      terminator = s
      while pcdata.match(terminator) do
        terminator += s
      end
      log_puts("PCDATA\t<<#{terminator}")
      log_puts(pcdata)
      log_puts(terminator)
    end
    start_time = Time.new if duration_to_be_included
    if block_given?
      if block_to_be_rescued
        begin
          yield
        rescue Exception => x
          put_element('rescued_exception') do
            put_element('class', x.class)
            put_element('message', x.message)
            put_element('backtrace') do
              filter_backtrace(x.backtrace).each_with_index do |location, i|
                put_element("level_#{i}", {:location => location})
              end
            end
          end
          self.counts[:error] += 1
        end
      else
        yield
      end
    end
    if start_time
      end_time = Time.now
      duration_f = end_time.to_f - start_time.to_f
      duration_s = format('%.3f', duration_f)
      put_attributes({:duration_seconds => duration_s})
    end
    log_puts("END\t#{element_name}")
    nil
  end

  def put_each_with_index(name, obj)
    lines = ['']
    obj.each_with_index do |item, i|
      lines.push(format('%6d %s', i, item.to_s))
    end
    lines.push('')
    lines.push('')
    put_element('each_with_index', :name => name, :class => obj.class, :size => obj.size) do
      put_cdata(lines.join("\n"))
    end
    nil
  end
  alias put_array put_each_with_index
  alias put_set put_each_with_index

  def put_each(name, obj)
    lines = ['']
    i = 0
    obj.each do |item|
      lines.push(format('%6d %s', i, item.to_s))
      i += 1
    end
    lines.push('')
    lines.push('')
    put_element('data', :name => name, :class => obj.class, :size => obj.size, :method => ':each') do
      put_cdata(lines.join("\n"))
    end
    nil
  end

  def put_each_pair(name, obj)
    lines = ['']
    obj.each_pair do |key, value|
      lines.push(format('%s => %s', key, value))
    end
    lines.push('')
    lines.push('')
    put_element('data', :name => name, :class => obj.class, :size => obj.size, :method => ':each_pair') do
      put_cdata(lines.join("\n"))
    end
    nil
  end
  alias put_hash put_each_pair

  def put_to_s(name, obj)
    put_element('data',  obj.to_s, :name => name, :class => obj.class, :method => ':to_s')
  end

  def put_string(name, obj)
    put_element('data',  obj.to_s, :name => name, :class => obj.class, :size => obj.size)
  end

  def put_inspect(name, obj)
    put_element('data',  obj.inspect, :name => name, :class => obj.class, :method => ':inspect')
  end

  def put_data(name, obj)
    case
    when obj.kind_of?(String)
      put_string(name, obj)
    when obj.respond_to?(:each_pair)
      put_each_pair(name, obj)
    when obj.respond_to?(:each_with_index)
      put_each_with_index(name, obj)
    when obj.respond_to?(:each)
      put_each(name, obj)
    when obj.respond_to?(:to_s)
      put_to_s(name, obj)
    else
      put_inspect(name, obj)
    end
  end

  private

  def initialize(file_path, options=Hash.new, im_ok_youre_not_ok = false)
    unless im_ok_youre_not_ok
      # Caller should call MinitestLog.open, not MinitestLog.new.
      message = "Please use #{self.class}.open, not #{self.class}.new.\n"
      raise RuntimeError.new(message)
    end
    self.assertions = 0
    self.file_path = file_path
    self.root_name = options[:root_name]
    self.xml_indentation = options[:xml_indentation]
    self.backtrace_filter = options[:backtrace_filter] || /log|ruby/
    self.file = File.open(self.file_path, 'w')
    log_puts("REMARK\tThis text log is the precursor for an XML log.")
    log_puts("REMARK\tIf the logged process completes, this text will be converted to XML.")
    log_puts("BEGIN\t#{self.root_name}")
    self.counts = Hash[
        :verdict => 0,
        :failure => 0,
        :error => 0,
    ]
    nil
  end

  def dispose

    # Close the text log.
    log_puts("END\t#{self.root_name}")
    self.file.close

    # Create the xml log.
    document = REXML::Document.new
    File.open(self.file_path, 'r') do |file|
      element = document
      stack = Array.new
      data_a = nil
      terminator = nil
      file.each_line do |line|
        line.chomp!
        line_type, text = line.split("\t", 2)
        case line_type
          when 'REMARK'
            next
          when 'BEGIN'
            element_name = text
            element = element.add_element(element_name)
            stack.push(element)
            if stack.length == 1
              summary_element = element.add_element('summary')
              summary_element.add_attribute('verdicts', self.counts[:verdict].to_s)
              summary_element.add_attribute('failures', self.counts[:failure].to_s)
              summary_element.add_attribute('errors', self.counts[:error].to_s)
            end
          when 'END'
            stack.pop
            element = stack.last
          when 'ATTRIBUTE'
            attr_name, attr_value = text.split("\t", 2)
            element.add_attribute(attr_name, attr_value)
          when 'CDATA'
            stack.push(:cdata)
            data_a = Array.new
            terminator = text.split('<<', 2).last
          when 'PCDATA'
            stack.push(:pcdata)
            data_a = Array.new
            terminator = text.split('<<', 2).last
          when terminator
            data_s = data_a.join("\n")
            data_a = nil
            terminator = nil
            data_type = stack.last
            case data_type
              when :cdata
                cdata = CData.new(data_s)
                element.add(cdata)
              when :pcdata
                element.add_text(data_s)
              else
                # Don't want to raise an exception and spoil the run
            end
            stack.pop
          else
            data_a.push(line) if (terminator)
        end
      end
      document << XMLDecl.default
    end

    File.open(self.file_path, 'w') do |file|
      document.write(file, self.xml_indentation)
    end
    # Trailing newline.
    File.open(self.file_path, 'a') do |file|
      file.write("\n")
    end
    nil
  end

  def _get_verdict?(verdict_method, verdict_id, message, args_hash)
    assertion_method = assertion_method_for(verdict_method)
    if block_given?
      outcome, exception = get_assertion_outcome(verdict_id, assertion_method, *args_hash.values) do
        yield
      end
    else
      outcome, exception = get_assertion_outcome(verdict_id, assertion_method, *args_hash.values)
    end
    element_attributes = {
        :method => verdict_method,
        :outcome => outcome,
        :id => verdict_id,
    }
    element_attributes.store(:message, message) unless message.nil?
    put_element('verdict', element_attributes) do
      args_hash.each_pair do |k, v|
        put_element(k.to_s, v)
      end
      if exception
        self.counts[:failure] += 1
        put_analysis(verdict_method, args_hash)
        put_element('exception', {:class => exception.class}) do
          put_element('message', exception.message)
          put_element('backtrace') do
            filter_backtrace(exception.backtrace).each_with_index do |location, i|
              put_element("level_#{i}", {:location => location})
            end
          end
        end
      end
    end
    outcome == :passed
  end

  def put_analysis(method, args_hash)
    # Log analysis of failed complex type.
    return unless method == :verdict_assert_equal?
    expected = args_hash[:exp_value]
    actual = args_hash[:act_value]
    [
        String,
        Integer,
    ].each do |class_to_exclude|
      return if expected.kind_of?(class_to_exclude)
      return if actual.kind_of?(class_to_exclude)
    end
    put_hash_analysis(expected, actual) ||
    put_set_analysis(expected, actual) ||
    put_array_analysis(expected, actual)
    # # Select helper class to perform comparison.
    # helper_class = nil
    # methods_for_helper_class = {
    #     HashHelper => [:each_pair],
    #     SetHelper => [:intersection, :difference],
    #     ArrayHelper => [:each],
    # }
    # methods_for_helper_class.each_pair do |klass, methods|
    #   methods.each do |helper_method|
    #     next unless expected.respond_to?(helper_method)
    #     next unless actual.respond_to?(helper_method)
    #     helper_class = klass
    #     break
    #   end
    #   break if helper_class
    # end
    # return unless helper_class
    # # Get and log the analysis.
    # attrs = {
    #     :expected_class => expected.class,
    #     :actual_class => actual.class,
    #     :methods => methods_for_helper_class[helper_class],
    # }
    # put_element('analysis', attrs) do
    #   helper_class.send(:compare, expected, actual).each_pair do |key, value|
    #     put_element(key.to_s, value) unless value.empty?
    #   end
    # end

  end

  def objects_can_handle(methods, expected, actual)
    [expected, actual].each do |obj|
      methods.each do |method|
        return false unless obj.respond_to?(method)
      end
    end
    true
  end

  def put_hash_analysis(expected, actual)
    return unless objects_can_handle([:each_pair], expected, actual)
    result = {
        :missing => {},
        :unexpected => {},
        :changed => {},
        :ok => {},
    }
    expected.each_pair do |key_expected, value_expected|
      if actual.include?(key_expected)
        value_actual = actual[key_expected]
        if value_actual == value_expected
          result[:ok][key_expected] = value_expected
        else
          result[:changed][key_expected] = {:expected => value_expected, :actual => value_actual}
        end
      else
        result[:missing][key_expected] = value_expected
      end
    end
    actual.each_pair do |key_actual, value_actual|
      next if expected.include?(key_actual)
      result[:unexpected][key_actual] = value_actual
    end
    attrs = {
        :expected_class => expected.class,
        :actual_class => actual.class,
        :methods => [:each_pair],
    }
    put_element('analysis', attrs) do
      result.each_pair do |key, value|
        put_element(key.to_s, value)
      end
    end
    true
  end

  def put_set_analysis(expected, actual)
    return unless objects_can_handle([:intersection, :difference], expected, actual)
    result = {
        :missing => expected.difference(actual),
        :unexpected => actual.difference(expected),
        :ok => expected.intersection(actual),
    }
    attrs = {
        :expected_class => expected.class,
        :actual_class => actual.class,
        :methods => [:each_pair],
    }
    put_element('analysis', attrs) do
      result.each_pair do |key, value|
        put_element(key.to_s, value)
      end
    end
    true
  end

  def put_array_analysis(expected, actual)
    return unless objects_can_handle([:each], expected, actual)
    sdiff = Diff::LCS.sdiff(expected, actual)
    changes = {}
    statuses = {
        '!' => 'changed',
        '+' => 'unexpected',
        '-' => 'missing',
        '=' => 'unchanged'
    }
    sdiff.each_with_index do |change, i|
      status = statuses.fetch(change.action)
      key = "change_#{i}"
      change_data = {
          :status => status,
          :old => "pos=#{change.old_position} ele=#{change.old_element}",
          :new => "pos=#{change.new_position} ele=#{change.new_element}",
      }
      changes.store(key, change_data)
    end
    attrs = {
        :expected_class => expected.class,
        :actual_class => actual.class,
        :methods => [:each_pair],
    }
    put_element('analysis', attrs) do
      changes.each_pair do |key, change_data|
        status = change_data.delete(:status)
        change_data.delete(:old) if status == 'unexpected'
        change_data.delete(:new) if status == 'missing'
        put_element(status) do
          change_data.each_pair do |k, v|
            put_element(k.to_s, v)
          end
        end
      end
    end
    true
  end

  def put_attributes(attributes)
    attributes.each_pair do |name, value|
      value = case
                when value.is_a?(String)
                  value
                when value.is_a?(Symbol)
                  value.to_s
                else
                  value.inspect
              end
      log_puts("ATTRIBUTE\t#{name}\t#{value}")
    end
    nil
  end

  def log_puts(text)
    self.file.puts(text)
    self.file.flush
    nil
  end

  def validate_verdict_id(verdict_id)
    self.verdict_ids ||= Set.new
    if self.verdict_ids.include?(verdict_id)
      message = format('Duplicate verdict id %s;  must be unique within its test method', verdict_id.inspect)
      raise ArgumentError.new(message)
    end
    self.verdict_ids.add(verdict_id)
    nil
  end

  def get_assertion_outcome(verdict_id, assertion_method, *assertion_args)
    validate_verdict_id(verdict_id)
    self.counts[:verdict] += 1
    begin
      if block_given?
        send(assertion_method, *assertion_args) do
          yield
        end
      else
        send(assertion_method, *assertion_args)
      end
      return :passed, nil
    rescue Minitest::Assertion => x
      return :failed, x
    end
  end

  def cdata(text)
    # Guard against using a terminator that's a substring of the cdata.
    s = 'EOT'
    terminator = s
    while text.match(terminator) do
      terminator += s
    end
    log_puts("CDATA\t<<#{terminator}")
    log_puts(text)
    log_puts(terminator)
    nil
  end

  # Filters lines that are from ruby or log, to make the backtrace more readable.
  def filter_backtrace(lines)
    filtered = []
    lines.each do |line|
      unless line.match(self.backtrace_filter)
        filtered.push(line)
      end
    end
    filtered
  end

  # Return a timestamp string.
  # The important property of this string
  # is that it can be incorporated into a legal directory path
  # (i.e., has no colons, etc.).
  def self.timestamp
    now = Time.now
    ts = now.strftime('%Y-%m-%d-%a-%H.%M.%S')
    usec_s = (now.usec / 1000).to_s
    while usec_s.length < 3 do
      usec_s = '0' + usec_s
    end
    # noinspection RubyUnusedLocalVariable
    ts += ".#{usec_s}"
  end

  def assertion_method_for(verdict_method)
    # Our verdict method name is just an assertion method name
    # with prefixed 'verdict_' and suffixed '?'.
    # Just remove them to form the assertion method name.
    verdict_method.to_s.sub('verdict_', '').sub('?', '').to_sym
  end

end
