# Used to prepare text before sending it to the main analysis.
# For now, just used to strip tags and punctuation
class TextPreprocessor
  attr_accessor :original_text, :processed_text

  def initialize(text)
    @original_text = text
    @processed_text = text
  end

  # quick way to perform multiple operations
  def perform(operations=[])
    operations.each do |operation|
      p "Operation: #{operation}"
      self.send(operation) if self.respond_to?(operation)
    end
  end

  def strip_tags
    @processed_text.gsub!(/<.+?>/, '')
  end

  def strip_punctuation
    @processed_text.gsub!(/[\.,!\?"']+/, '')
  end
end
