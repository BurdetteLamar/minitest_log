$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'minitest_log'
require 'tmpdir'
require 'minitest/autorun'
require 'rexml/document'

module TestHelper

  include REXML

  def _test(name, open_options = {})
    file_name = "#{name}.xml"
    file_path = actual_file_path(file_name)
    MinitestLog.open(file_path, open_options) do |log|
      yield log
    end
    condition_file(file_path)
    assert_file(file_name)
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
    assert_empty(diff, "File name: #{file_name}")
  end

  def condition_file(file_path)
    content = File.read(file_path)

    timestamp_regexp = /timestamp='\d{4}-\d{2}-\d{2}-\w{3}-\d{2}\.\d{2}\.\d{2}\.\d{3}'/
    timestamp_dummy = '0000-00-00-xxx-00.00.00.000'
    content.gsub!(timestamp_regexp, "timestamp='#{timestamp_dummy}'")

    duration_regexp = /duration_seconds='\d.\d{3}'/
    duration_dummy = '0.000'
    content.gsub!(duration_regexp, "duration_seconds='#{duration_dummy}'")

    oid_regexp = /\(oid=\d+\)/
    oid_dummy = '00000000'
    content.gsub!(oid_regexp, "oid=(#{oid_dummy})")

    File.write(file_path, content)
  end

end