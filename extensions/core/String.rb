class String
  # Returns the word count in a phrase
  def word_count
    self.split(' ').count
  end

  # Returns the last word of a phrase
  def last_word
    self.split(' ').last
  end
end
