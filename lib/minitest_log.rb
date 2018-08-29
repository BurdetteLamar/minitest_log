require 'rexml/document'
require 'minitest/autorun'
require 'minitest/assertions'
require 'nokogiri'

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

  # Message for no block error.
  NO_BLOCK_GIVEN_MSG = 'No block given'
  # Message for calling-new error.
  NO_NEW_MSG = format('Please use %s.open, not %s.new.', self.class.name, self.class.name)

  def self.open(options=Hash.new)
    raise NO_BLOCK_GIVEN_MSG unless (block_given?)
    default_options = Hash[
        :file_path => File.join(DEFAULT_DIR_PATH, DEFAULT_FILE_NAME),
        :root_name => DEFAULT_XML_ROOT_TAG_NAME,
        :xml_indentation => DEFAULT_XML_INDENTATION
    ]
    options = default_options.merge(options)
    log = self.new(options, im_ok_youre_not_ok = true)
    yield log
    log.send(:dispose)
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

  private

  def initialize(options=Hash.new, im_ok_youre_not_ok = false)
    unless im_ok_youre_not_ok
      # Caller should call MinitestLog.open, not MinitestLog.new.
      raise RuntimeError.new(NO_NEW_MSG)
    end
    self.assertions = 0
    self.file_path = options[:file_path]
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
      formatter = REXML::Formatters::Pretty.new(2)
      formatter.compact = true
      formatter.write(document, file)
    end
    # Trailing newline.
    File.open(self.file_path, 'a') do |file|
      file.write("\n")
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
          # Get the verdict id (for the verdict that was attempted).
          verdict_id = nil
          args.each do |arg|
            next unless arg.respond_to?(:each_pair)
            next unless arg.include?(:name)
            verdict_id = arg[:name]
            break
          end
          put_element('uncaught_exception') do
            put_element('verdict_id', verdict_id) if verdict_id
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
    return unless expected.class == actual.class
    case
      when expected.kind_of?(Set)
        put_element('analysis') do
          SetHelper.compare(expected, actual).each_pair do |key, value|
            put_element(key.to_s, value) unless value.empty?
          end
        end
      when expected.kind_of?(Hash)
        put_element('analysis') do
          HashHelper.compare(expected, actual).each_pair do |key, value|
            put_element(key.to_s, value) unless value.empty?
          end
        end
      else
        # TODO:  Implement more here as needed;  Array, etc.
    end

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
