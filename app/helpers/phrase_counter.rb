# Used to count occurrances of phrases in text
# Can also be used for simple word count, by giving range of 1
class PhraseCounter
  attr_accessor :phrases

  def initialize(text, options = { min_phrase_length: 3 })
    @text_array = text.downcase.split(/\s+/)
    phrase_options(options)
    @phrases = {}
  end

  # Set the options for the phrase counter (e.g. min words per phrase)
  def phrase_options(new_options = nil)
    @options ||= {}
    return @options unless new_options
    min_length = new_options[:min_phrase_length] || new_options[:max_phrase_length]
    max_length = new_options[:max_phrase_length] || new_options[:min_phrase_length]

    @options[:phrase_length_range] = min_length..max_length
    @options
  end

  # Performs the phrase counting
  def perform
    phrase_options[:phrase_length_range].each do |length|
      @phrases[length] = Hash.new(0) # Default each phrase to zero occurances
      each_phrase(length) do |phrase|
        @phrases[length][phrase] += 1
      end
    end
    nil
  end

  # Iterates over the words array, and returns each phrase of agument length
  def each_phrase(length)
    max_index = @text_array.length - length
    (0..max_index).each  do |index|
      yield @text_array.slice(index, length).join(' ')
    end
  end
end
