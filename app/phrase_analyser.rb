require './app/helpers/text_preprocessor'
require './app/helpers/phrase_counter'

class PhraseAnalyser
  attr_accessor :analysis, :text

  def initialize(text, options)

    @text = text
    perform(options)
  end

  def perform(options)
    text_pp = TextPreprocessor.new(@text)
    @text = text_pp.perform(options[:preprocessor].keys)

    phrase_counter = PhraseCounter.new(@text, options[:counter])
    @analysis = phrase_counter.perform
  end
end
