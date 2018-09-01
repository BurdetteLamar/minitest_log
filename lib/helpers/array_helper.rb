require 'diff/lcs'

class ArrayHelper

  # Compare two arrays.
  def self.compare(expected, actual)
    sdiff = Diff::LCS.sdiff(expected, actual)
    changes = {}
    action_words = {
        '!' => 'changed',
        '+' => 'unexpected',
        '-' => 'missing',
        '=' => 'unchanged'
    }
    sdiff.each_with_index do |change, i|
      action_word = action_words.fetch(change.action)
      key = "change_#{i}"
      attrs = [
          "action=#{action_word}",
          "old_pos=#{change.old_position}",
          "old_ele=#{change.old_element}",
          "new_pos=#{change.old_position}",
          "new_ele=#{change.old_element}",
      ]
      value = attrs.join(' ')
      changes.store(key, value)
    end
    {:sdiff => changes}
  end

end
