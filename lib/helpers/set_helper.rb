class SetHelper

  # Compare two sets.
  # Returns a hash with keys +:ok+, +:missing+, +:unexpected+.
  def self.compare(expected, actual)
    {
        :missing => expected - actual,
        :unexpected => actual - expected,
        :ok => expected & actual,
    }
  end

end

