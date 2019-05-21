require 'rexml/document'
require 'minitest/autorun'
require 'minitest/assertions'
require 'diff/lcs'

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
    self.file_path = file_path
    handle_options(options)
    begin_log
    begin
      yield self
    rescue => x
      handle_exception(x)
    end
    dispose
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

  class Element

    attr_accessor \
        :args,
        :attributes,
        :block_to_be_rescued,
        :duration_to_be_included,
        :element_name,
        :log,
        :pcdata,
        :start_time

    def initialize(log, element_name, *args)

      self.log = log
      self.element_name = element_name
      self.args = args

      self.attributes = {}
      self.block_to_be_rescued = false
      self.duration_to_be_included = false
      self.pcdata = ''
      self.start_time = nil

      process_args
      begin_element
      put_attributes
      put_pcdata
      begin_duration
      if block_given?
        if self.block_to_be_rescued
          begin
            yield
          rescue Exception => x
            log.put_element('rescued_exception', {:class => x.class, :message => x.message}) do
              log.put_element('backtrace') do
                backtrace = log.send(:filter_backtrace, x.backtrace)
                log.put_pre(backtrace.join("\n"))
              end
            end
            log.counts[:error] += 1
          end
        else
          yield
        end
      end
      end_duration
      log.send(:log_puts, "END\t#{self.element_name}")
      nil
    end

    def process_args
      args.each do |arg|
        case
        when arg.kind_of?(Hash)
          self.attributes.merge!(arg)
        when arg.kind_of?(String)
          self.pcdata += arg
        when arg == :timestamp
          self.attributes[:timestamp] = MinitestLog.timestamp
        when arg == :duration
          self.duration_to_be_included = true
        when arg == :rescue
          self.block_to_be_rescued = true
        else
          self.pcdata = self.pcdata + arg.inspect
        end
      end
    end

    def begin_element
      log.send(:log_puts, "BEGIN\t#{element_name}")
    end

    def put_attributes
      log.send(:put_attributes, attributes)
    end

    def put_pcdata
      unless pcdata.empty?
        # Guard against using a terminator that's a substring of pcdata.
        s = 'EOT'
        terminator = s
        while pcdata.match(terminator) do
          terminator += s
        end
        log.send(:log_puts, "PCDATA\t<<#{terminator}")
        log.send(:log_puts, pcdata)
        log.send(:log_puts, terminator)
      end
    end

    def begin_duration
      self.start_time = Time.new if duration_to_be_included
    end

    def end_duration
      if duration_to_be_included
        end_time = Time.now
        duration_f = end_time.to_f - start_time.to_f
        duration_s = format('%.3f', duration_f)
        log.send(:put_attributes, {:duration_seconds => duration_s})
      end
    end

  end

  def put_element(element_name = 'element', *args)
    conditioned_element_name = condition_element_name(element_name, caller[0])
    if block_given?
      Element.new(self, conditioned_element_name, *args, &Proc.new)
    else
      Element.new(self, conditioned_element_name, *args)
    end
  end

  def put_each_with_index(name, obj)
    lines = ['']
    obj.each_with_index do |item, i|
      lines.push(format('%d: %s', i, item.to_s))
    end
    attrs = {
        :name => name,
        :class => obj.class,
        :method => ':each_with_index',
    }
    add_attr_if(attrs, obj, :size)
    put_element('data', attrs) do
      put_pre(lines.join("\n"))
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
    attrs = {
        :name => name,
        :class => obj.class,
        :method => ':each',
    }
    add_attr_if(attrs, obj, :size)
    put_element('data', attrs) do
      put_pre(lines.join("\n"))
    end
    nil
  end

  def put_each_pair(name, obj)
    lines = ['']
    obj.each_pair do |key, value|
      lines.push(format('%s => %s', key, value))
    end
    attrs = {
        :name => name,
        :class => obj.class,
        :method => ':each_pair',
    }
    add_attr_if(attrs, obj, :size)
    put_element('data', attrs) do
      put_pre(lines.join("\n"))
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

  def put_pre(text, verbatim = false)
    if verbatim
      put_cdata(text)
    else
      t = text.clone
      until t.start_with?("\n")
        t = "\n" + t
      end
      until t.end_with?("\n\n")
        t = t + "\n"
      end
      put_cdata(t)
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
        # If the encoding is not UTF-8, a string will have been added.
        # Remove it, so that the message is the same on all platforms.
        conditioned_message = exception.message.gsub("# encoding: UTF-8\n", '')
        put_element('exception', {:class => exception.class, :message => conditioned_message}) do
          put_element('backtrace') do
            backtrace = filter_backtrace(exception.backtrace)
            put_pre(backtrace.join("\n"))
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
    "#{ts}.#{usec_s}"
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

  def condition_element_name(element_name, caller_0)
    if caller_is_us?(caller_0)
      conditioned_element_name = element_name + '_'
    elsif element_name.end_with?('_')
      message = "Element name should not end with underscore: #{element_name}"
      raise IllegalElementNameError.new(message)
    else
      conditioned_element_name = element_name
    end
    conditioned_element_name
  end

  def caller_is_us?(caller_0)
    caller_0.match(/minitest_log.rb/) || caller_0.match(/verdict_assertion.rb/)
  end

  def handle_options(options)
    default_options = Hash[
        :root_name => 'log',
        :xml_indentation => 2,
        :error_verdict => false,
        :summary => false
    ]
    options = default_options.merge(options)
    self.root_name = options[:root_name]
    self.xml_indentation = options[:xml_indentation]
    self.summary = options[:summary]
    self.error_verdict = options[:error_verdict] || false
    self.backtrace_filter = options[:backtrace_filter] || /minitest/
  end

  def begin_log
    self.counts = Hash[
        :verdict => 0,
        :failure => 0,
        :error => 0,
    ]
    self.assertions = 0
    self.file = File.open(self.file_path, 'w')
    log_puts("REMARK\tThis text log is the precursor for an XML log.")
    log_puts("REMARK\tIf the logged process completes, this text will be converted to XML.")
    log_puts("BEGIN\t#{self.root_name}")
  end

  def handle_exception(x)
    put_element('uncaught_exception', :timestamp, :class => x.class) do
      put_element('message', x.message)
      put_element('backtrace') do
        backtrace = filter_backtrace(x.backtrace)
        put_pre(backtrace.join("\n"))
      end
    end
  end

end
