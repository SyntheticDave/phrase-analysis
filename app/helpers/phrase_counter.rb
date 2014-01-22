require 'pry'

# Used to count occurrances of phrases in text
# Can also be used for simple word count, by giving range of 1
class PhraseCounter
  attr_accessor :phrases

  def initialize(text, options = { min_length: 3 })
    @text_array = text.downcase.split(/\s+/)
    phrase_options(options)
    @phrases = {}

    # Used to keep track of multiple phrase matches in a row, to find longer phrases
    @running_phrases = []

    # Keeps track of component phrases, to be removed after a pass is completed
    @component_phrases = Hash.new(0)
  end

  # Set the options for the phrase counter (e.g. min words per phrase)
  def phrase_options(new_options = nil)
    @options ||= {}
    return @options unless new_options

    # Set phrase length range
    min_length = new_options[:min_length] || new_options[:max_length]
    max_length = new_options[:max_length] || new_options[:min_length]

    @options[:length_range] = (min_length.to_i)..(max_length.to_i)
    @options[:min_length] = min_length.to_i
    @options[:max_length] = max_length.to_i

    # set longer phrase options
    @options[:look_longer] = new_options[:look_longer]
    @options[:hide_longer] = new_options[:hide_longer]

    @options
  end

  def word_count
    @word_count ||= @text_array.count
  end

  # Performs the phrase counting
  def perform
    phrase_options[:length_range].each do |length|
      @phrases[length] ||= Hash.new(0) # Default each phrase to zero occurances
      each_phrase(length) do |phrase|
        running_phrase_check(length, phrase) if @options[:look_longer] && (length == @options[:max_length])
        @phrases[length][phrase] += 1
      end

      # Check for presence of longer phrases only on last pass
      running_phrase_check(length, '') if @options[:look_longer] && (length == @options[:max_length])
    end

    remove_component_phrases if @options[:hide_longer]
    sort_phrases
  end

  def sort_phrases
    @phrases = Hash[@phrases.sort_by{|length, _| length}]
    @phrases.each do |length, phrases|
      @phrases[length] = Hash[@phrases[length].sort_by{|_, occurances| occurances}.reverse]
    end
  end

  # Keeps a running list of sequentially matching phrases, to find longer phrases than currently being checked for
  def running_phrase_check(length, phrase)
    # Check if this phrase has been found before
    if @phrases[length][phrase] > 0
      @running_phrases << phrase
    else # Not found, so we are at the end of any longer phrase (if one exists)
      if @running_phrases.count > 1
        # Found more than one matching phrase in a row
        record_longer_phrase
      end
      @running_phrases.clear
    end
  end

  # Compiles component phrases into their complete phrase, and records in result set
  def record_longer_phrase
    compiled_phrase = compile_phrase
    compiled_phrase_length = phrase_length(compiled_phrase)
    @phrases[compiled_phrase_length] ||= Hash.new(0)

    # The first duplicate we find needs to record both occurrances
    # TODO: Clean this up. Absolute mother to read.
    new_occurrances = @phrases[compiled_phrase_length][compiled_phrase] > 0 ? 1 : 2
    @phrases[compiled_phrase_length][compiled_phrase] += new_occurrances
  end

  # Iterates over the text array, and returns each phrase of agument length
  def each_phrase(length, text_array=nil)
    text_array ||= @text_array
    length = length.to_i
    max_index = text_array.length - length
    (0..max_index).each  do |index|
      yield text_array.slice(index, length).join(' ')
    end
  end

  # Compiles phrase components into their complete phrase
  # Returns the compiled phrase and its length
  def compile_phrase
    # Make sure we dup the value, so we don't alter @running_phrases
    compiled_phrase = @running_phrases.first.dup

    @running_phrases.each do |component_phrase|
      next if compiled_phrase == component_phrase
      compiled_phrase << ' ' + component_phrase.split(' ').last
    end

    compiled_phrase
  end

  def remove_component_phrases
    @phrases = Hash[@phrases.sort_by{|length, _| length}.reverse]
    @phrases.each do |length, phrases|
      phrases.each do |phrase, occurrances|
        remove_component_phrase(phrase, length, occurrances) if occurrances > 1
      end
    end
  end

  def remove_component_phrase(phrase, length, occurrances)
    (@options[:min_length]..(length - 1)).each do |component_length|
      return unless @phrases[component_length]

      phrase_array = phrase.split(' ')

      each_phrase(component_length, phrase_array) do |component_phrase|
        if @phrases[component_length][component_phrase]
          # p "Removing #{occurrances} occurrances of '#{component_phrase}' from results"
          @phrases[component_length][component_phrase] -= occurrances
          @phrases[component_length].delete(component_phrase) if @phrases[component_length][component_phrase] <= 0
        end
      end
    end
  end

  # Returns the number of words in a phrase
  # TODO: Move this somewhere better
  def phrase_length(phrase)
    phrase.split(' ').count
  end
end
