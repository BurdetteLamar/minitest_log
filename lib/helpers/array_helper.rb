require 'diff/lcs'

class ArrayHelper

  # Compare two arrays.
  def self.compare(expected, actual)
    {:diff => Diff::LCS.diff(expected, actual)}
  end

end

