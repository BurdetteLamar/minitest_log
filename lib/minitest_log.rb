require 'rexml/document'
require 'minitest/autorun'
require 'minitest/assertions'

require 'diff/lcs'

require_relative 'helpers/array_helper'
require_relative 'helpers/hash_helper'
require_relative 'helpers/set_helper'

# When adding a module here, be sure to 'include' below.
require_relative 'verdict_assertion'

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
    :xml_indentation,
    :error_verdict,
    :summary

  include REXML
  include Minitest::Assertions

  class MinitestLogError < Exception; end
  class NoBlockError < MinitestLogError; end
  class DuplicateVerdictIdError < MinitestLogError; end
  class IllegalElementNameError < MinitestLogError; end
  class IllegalNewError < MinitestLogError; end

  def initialize(file_path, options=Hash.new)
    raise NoBlockError.new('No block given for MinitestLog#new.') unless (block_given?)
    default_options = Hash[
        :root_name => 'log',
        :xml_indentation => 2,
        :error_verdict => false,
        :summary => false
    ]
    options = default_options.merge(options)
    self.assertions = 0
    self.file_path = file_path
    self.root_name = options[:root_name]
    self.xml_indentation = options[:xml_indentation]
    self.summary = options[:summary]
    self.error_verdict = options[:error_verdict] || false
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
    begin
      yield self
    rescue => x
      put_element('uncaught_exception', :timestamp, :class => x.class) do
        put_element('message', x.message)
        put_element('backtrace') do
          backtrace = filter_backtrace(x.backtrace)
          put_cdata(backtrace.join("\n"))
        end
      end
    end
    dispose
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
      yield if block_given?
    end
    nil
  end

  def comment(text)
    if text.match("\n")
      # Separate text from containing punctuation.
      put_element('comment') do
        cdata("\n#{text}\n")
      end
    else
      put_element('comment', text)
    end
    nil
  end

  def put_element(element_name = 'element', *args)
    if false ||
        caller[0].match(/minitest_log.rb/) ||
        caller[0].match(/verdict_assertion.rb/)
      # Make the element name special.
      element_name += '_'
    elsif element_name.end_with?('_')
      # Don't accept user's special.
      message = "Element name should not end with underscore: #{element_name}"
      raise IllegalElementNameError.new(message)
    else
      # Ok.
    end
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
          put_element('rescued_exception', {:class => x.class, :message => x.message}) do
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
      lines.push(format('%d: %s', i, item.to_s))
    end
    lines.push('')
    lines.push('')
    attrs = {
        :name => name,
        :class => obj.class,
        :method => ':each_with_index',
    }
    add_attr_if(attrs, obj, :size)
    put_element('data', attrs) do
      put_cdata(lines.join("\n"))
    end
    nil
  end
  alias put_array put_each_with_index
  alias put_set put_each_with_index

  def put_each(name, obj)
    lines = ['']
    obj.each do |item|
      lines.push(item)
    end
    lines.push('')
    lines.push('')
    attrs = {
        :name => name,
        :class => obj.class,
        :method => ':each',
    }
    add_attr_if(attrs, obj, :size)
    put_element('data', attrs) do
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
    attrs = {
        :name => name,
        :class => obj.class,
        :method => ':each_pair',
    }
    add_attr_if(attrs, obj, :size)
    put_element('data', attrs) do
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

  def put_id(name, obj)
    put_element('data', :name => name, :class => obj.class, :id => obj.__id__)
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
    when obj.respond_to?(:inspect)
      put_inspect(name, obj)
    when obj.respond_to?(:__id__)
      put_id(name, obj)
    else
      message = "Object does not respond to method :__id__: name=#{name}, obj=#{obj}"
      raise ArgumentError.new(message)
    end
  end

  private

  def dispose

    # Add a verdict for the error count, if needed.
    if self.error_verdict
      verdict_assert_equal?('error_count', 0, self.counts[:error])
    end

    # Close the text log.
    log_puts("END\t#{self.root_name}")
    self.file.close

    # Create the xml log.
    document = REXML::Document.new
    File.open(self.file_path, 'r') do |file|
      element = document
      stack = Array.new
      data_a = Array.new
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
            if stack.length == 1 && self.summary
              summary_element = element.add_element('summary_')
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
            data_a = Array.new
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
        put_element(k.to_s, {:class => v.class, :value => v.inspect})
      end
      if exception
        self.counts[:failure] += 1
        put_element('exception', {:class => exception.class, :message => exception.message}) do
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
      raise DuplicateVerdictIdError.new(message)
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

  def add_attr_if(attrs, obj, method)
    return unless obj.respond_to?(method)
    attrs[method] = obj.send(method)
  end

  def self.parse(file_path)
    document = nil
    File.open(file_path) do |file|
      document = REXML::Document.new(file)
    end
    document
  end

end
