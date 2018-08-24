module VerdictInteger

  # TODO:  Create test for this module.
  # TODO:  Create examples for this module.

  def verdict_assert_integer_positive?(verdict_id, actual, message: nil, volatile: false)
    passed = true
    section(__method__.to_s) do
      passed = va_kind_of?([verdict_id, :integer], Integer, actual, message: message, volatile: volatile) && passed
      passed = va_operator?([verdict_id, :positive], actual, :>, 0, message: message, volatile: volatile) && passed
    end
    passed
  end
  alias va_integer_positive? verdict_assert_integer_positive?

end