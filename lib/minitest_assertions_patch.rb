module Minitest
  module Assertions
    # Minitest uses a platform-dependent program for diff.
    # Here, we already have diff-lcs available, so always use that.
    def self.diff
      'ldiff -u 0'
    end
  end
end
