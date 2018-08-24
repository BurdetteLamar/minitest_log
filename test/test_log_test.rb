require 'test_helper'

class TestLogTest < Minitest::Test
  def test_version_number
    refute_nil ::TestLog::VERSION
  end

end
