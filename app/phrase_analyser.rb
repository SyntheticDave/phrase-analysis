require './app/helpers/text_preprocessor'
require './app/helpers/phrase_counter'

class PhraseAnalyser
  attr_accessor :analysis, :text, :word_count, :hide_less_than

  def initialize(text, options)

    @text = text
    @hide_less_than = options[:display][:hide_less_than].to_i
    perform(options)
  end

  def perform(options)
    text_pp = TextPreprocessor.new(@text)
    @text = text_pp.perform(options[:preprocessor].keys)

    phrase_counter = PhraseCounter.new(@text, options[:counter])
    @analysis = phrase_counter.perform
    @word_count = phrase_counter.word_count
  end
end
