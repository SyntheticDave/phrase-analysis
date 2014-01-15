class PhraseCounter
  attr_accessor :phrases

  def initialize(text, options={min_phrase_length: 3, max_phrase_length: 3})
    @text_array = text.downcase.split(/\s+/)
    set_options(options)
    @phrases = {}
  end

  # Set the options for the phrase counter (e.g. min words per phrase, max words per phrase)
  def set_options(options)
    @phrase_length_range = options[:min_phrase_length]..options[:max_phrase_length]
  end

  # Performs the phrase counting
  def perform
    @phrase_length_range.each do |length|
      @phrases[length] = Hash.new(0) # Default each phrase to zero occurances
      each_phrase(length) do |phrase|
        p phrase
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
