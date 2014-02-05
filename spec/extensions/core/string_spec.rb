require 'spec_helper'

describe String do
  let(:test_text) { 'this is a test' }

  describe '#word_count' do
    context 'given a string of 4 words' do
      subject { test_text.word_count }
      it      { should eq 4 }
    end
  end

  describe '#last_word' do
    context "given a phrase of 'this is a test'" do

      it 'returns the word, \'test\'' do
        expect(test_text.last_word).to eq 'test'
      end
    end

    context "given a phrase with trailing whitespace" do
      let(:test_text) { 'this is a test  ' }

      it 'returns the last word, ignoring whitespace' do
        expect(test_text.last_word).to eq 'test'
      end
    end

  end
end
