module VerdictString

  # TODO:  Create test for this module.
  # TODO:  Create examples for this module.

  def verdict_assert_string_not_empty?(verdict_id, actual, message: nil, volatile: false)
    passed = true
    section(__method__.to_s) do
      passed = va_kind_of?([verdict_id, :string], String, actual, message: message, volatile: volatile) && passed
      passed = vr_empty?([verdict_id, :not_empty], actual, message: message, volatile: volatile) && passed
    end
    passed
  end
  alias va_string_not_empty? verdict_assert_string_not_empty?

  def verdict_assert_string_length_in_range?(verdict_id, range, actual, message: nil, volatile: false)
    passed = true
    section(__method__.to_s) do
      passed = va_kind_of?([verdict_id, :string], String, actual, message: message, volatile: volatile) && passed
      passed = verdict_assert_in_range?([verdict_id, :in_range], range, actual.size, message: message, volatile: volatile) && passed
    end
    passed
  end
  alias va_string_length_in_range? verdict_assert_string_length_in_range?

end
