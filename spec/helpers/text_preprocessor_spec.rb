require 'spec_helper'
require './app/helpers/text_preprocessor'

describe TextPreprocessor do
  let(:text_pp) { TextPreprocessor.new(test_text) }
  let(:test_text) { 'This is a test string.' }

  describe '.initialize' do
    context 'when passed a string' do
      it 'assigns its argument string' do
        expect(text_pp.text).to eq(test_text)
      end
    end
  end

  describe '#strip_tags' do
    subject { text_pp.strip_tags }

    context 'with nothing to strip' do
      let(:test_text) { 'There are no tags to strip in this string.' }
      it 'does not alter the text' do
        expect(subject).to eq test_text
      end
    end

    context 'with tags to strip' do
      let(:test_text) { 'There are <i>some</i> <random>tags</random> to strip in this string.</br>' }
      it 'removes all tags' do
        expect(subject).to eq 'There are some tags to strip in this string.'
      end
    end
  end

  describe '#strip_punctuation' do
    subject { text_pp.strip_punctuation }

    context 'with nothing to strip' do
      let(:test_text) { 'This string has no punctuation to strip' }
      it 'does not alter the text' do
        expect(subject).to eq test_text
      end
    end

    context 'with punctuation to strip' do
      let(:test_text) { 'This !? string, has .some "punctuation"\' Also a hyphenated-word.' }

      it { should_not include '?' }
      it { should_not include'.' }
      it { should_not include'!' }
      it { should_not include',' }
      it { should_not include'"' }
      it { should_not include'\'' }

      it { should include '-' }
    end
  end

  describe '#perform' do
    context 'given known operations' do
      let(:operations) { [:strip_tags, :strip_punctuation] }
      it 'calls each operation' do
        text_pp.should_receive(:strip_tags)
        text_pp.should_receive(:strip_punctuation)

        text_pp.perform(operations)
      end
    end
    context 'given unknown operations' do
      let(:operations) { [:unknown_operation] }
      it 'does not raise an error' do
        expect { text_pp.perform }.to_not raise_error
      end
    end

  end
end
