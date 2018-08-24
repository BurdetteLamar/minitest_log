module VerdictBoolean

  # TODO:  Create test for this module.
  # TODO:  Create examples for this module.

  def verdict_assert_boolean?(verdict_id, actual, message: nil, volatile: false)
    boolean_classes = [
        TrueClass,
        FalseClass,
    ]
    va_includes?(verdict_id, boolean_classes, actual.class, message: message, volatile: volatile)
  end
  alias va_boolean? verdict_assert_boolean?

end
