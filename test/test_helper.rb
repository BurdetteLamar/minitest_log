$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'minitest_log'
require 'tmpdir'
require 'minitest/autorun'

module TestHelper

  # Yield an open log for testing, verify resulting log file.
  def with_test_log(name, open_options = {})
    file_name = "#{name}.xml"
    file_path = actual_file_path(file_name)
    MinitestLog.new(file_path, open_options) do |log|
      yield log
    end
    condition_file(file_path)
    assert_file(file_name)
  end

  def actual_file_path(file_name)
    dir_path = File.join('test', 'actual')
    Dir.mkdir(dir_path) unless File.directory?(dir_path)
    File.join(dir_path, file_name)
  end

  def expected_file_paths(file_name)
    # The expected file includes a message from minitest that can be platform-dependent.
    # Most times the message is the same for all platforms, so there's just one file
    # containing the expected output.
    exp_dir_path = File.join('test', 'expected')
    file_path = File.join(exp_dir_path, file_name)
    if File.file?(file_path)
      return [file_path]
    end
    # For a very few tests, the message from minitest *is* platform-dependent.
    # On some platforms, minitest will have performed a line diff.
    # On others, the expected and actual values are embedded in a 1-line message.
    # The 'expected' value in that case is not a file, but instead a folder of files.
    dir_name = File.basename(file_name, '.xml')
    dir_path = File.join(exp_dir_path, dir_name)
    file_paths = []
    Dir.entries(dir_path).each do |entry|
      next if entry.start_with?('.')
      file_paths.push(File.join(dir_path, entry))
    end
    file_paths
  end

  # Store content to actual file, verify against expected file.
  def store_and_assert(file_name, actual_content)
    File.write(actual_file_path(file_name), actual_content)
    assert_file(file_name)
  end

  # Assert actual and expected files do not differ.
  def assert_file(file_name)
    actual_content = File.readlines(actual_file_path(file_name))
    expected_file_paths(file_name).each do |expected_file_path|
      expected_content = File.readlines(expected_file_path)
      if expected_content == actual_content
        assert(true)
        return
      end
    end
    assert(false, "#{file_name}")
  end

  # Handle volatile file elements, so that diff is effective.
  def condition_file(file_path)
    content = File.read(file_path)

    # Timestamp.
    timestamp_regexp = /timestamp='\d{4}-\d{2}-\d{2}-\w{3}-\d{2}\.\d{2}\.\d{2}\.\d{3}'/
    timestamp_dummy = '0000-00-00-xxx-00.00.00.000'
    content.gsub!(timestamp_regexp, "timestamp='#{timestamp_dummy}'")

    # Duration.
    duration_regexp = /duration_seconds='\d.\d{3}'/
    duration_dummy = '0.000'
    content.gsub!(duration_regexp, "duration_seconds='#{duration_dummy}'")

    # Object ID.
    oid_regexp = /\(oid=\d+\)/
    oid_dummy = '00000000'
    content.gsub!(oid_regexp, "oid=(#{oid_dummy})")

    # Encoding.
    content.gsub!("# encoding: UTF-8\\n", '')

    # Windows phrase.
    content.gsub!('#    valid: true\n', '')

    File.write(file_path, content)
  end

end