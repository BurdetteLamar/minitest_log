# Class of convenience methods for assertions.
class AssertionHelper

  # The tools we're using lack assert_nothing_raised.
  # - +test+:  +Minitest::Test+ object, to make assertions available.
  # - +message+:  Message for assertion.
  def self.assert_nothing_raised(test, message = 'Nothing raised')
    x = nil
    begin
      yield
    rescue => y
      x = y
    end
    test.assert_nil(x, message: message)
  end

  # +assert_raises+, but with a message.
  # - +test+:  +Minitest::Test+ object, to make assertions available.
  # - +expected_class+:  exception class expected.
  # - +expected_message+:  message expected.
  def self.assert_raises_with_message(test, expected_class, expected_message)
    x = test.assert_raises(expected_class) do
      yield
    end
    test.assert_equal(expected_message, x.message, 'Exception message')
  end

end
