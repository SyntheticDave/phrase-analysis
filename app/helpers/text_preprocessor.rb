# Used to prepare text before sending it to the main analysis.
# For now, just used to strip tags and punctuation
class TextPreprocessor
  attr_accessor :text

  def initialize(text)
    @text = text
  end

  # quick way to perform multiple operations
  def perform(operations = [])
    operations.each do |operation|
      send(operation) if respond_to?(operation)
    end
  end

  def strip_tags
    @text.tap { |text| text.gsub!(/<.+?>/, '') }
  end

  def strip_punctuation
    @text.tap { |text| text.gsub!(/[\.,!\?"']+/, '') }
  end
end
