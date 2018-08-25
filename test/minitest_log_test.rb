require 'minitest_log/version'
require 'test_helper'

class TestLogTest < Minitest::Test
  def test_version_number
    refute_nil ::MinitestLog::VERSION
  end

end
