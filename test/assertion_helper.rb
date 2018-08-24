require 'contracts'

# Class of convenience methods for assertions.
class AssertionHelper

  include Contracts

  Contract Minitest::Test, Or[String, Proc], Maybe[Proc] => Bool
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

  Contract Minitest::Test, Any, String, Proc => Bool
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

  # Format for contract violation message;  used here and in self tests.
  CONTRACT_VIOLATION_MSG_FMT = 'Contract violation for argument %d of %d'

  Contract Num, Num => String
  # Return message for contract violation.
  # - +argument_index+:  0-based index of violated argument.
  # - +argument_count+:  count of arguments in contract.
  def self.contract_violation_message(argument_index, argument_count)
    format(CONTRACT_VIOLATION_MSG_FMT, 1 + argument_index, argument_count)
  end

  Contract Minitest::Test, Num, Num, Proc => nil
  # Assert a contract violation.
  # - +test+:  +Minitest::Test+ object, to make assertions available.
  # - +argument_index+:  0-based index of violated argument.
  # - +argument_count+:  count of arguments in contract.
  def self.assert_contract_violation(test, argument_index, argument_count)
    x = test.assert_raises ParamContractError do
      yield
    end
    expected_message = format(CONTRACT_VIOLATION_MSG_FMT, 1 + argument_index, argument_count)
    test.assert_match(expected_message, x.message, 'Error message')
    nil
  end

end
