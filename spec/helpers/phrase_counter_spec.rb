require 'spec_helper'
require './app/helpers/phrase_counter'

describe PhraseCounter do
  let(:test_text) { '' }
  let(:options)   { {min_phrase_length: 3, max_phrase_length: 3} }
  let(:pc)        { PhraseCounter.new(test_text, options) }

  describe '#set_options' do
    subject { pc.set_options(options) }

    describe 'phrase length' do
      context 'only min phrase length passed' do
        let(:options) { { min_phrase_length: 2 } }
        it 'uses min as both min and max of range' do
          expect(subject).to eq (2..2)
        end
      end
      context 'only max phrase length passed' do
        let(:options) { { max_phrase_length: 6 } }
        it 'uses max as both min and max of range' do
          expect(subject).to eq (6..6)
        end
      end
      context 'both min and max passed' do
        let(:options) { { min_phrase_length: 3, max_phrase_length: 6 } }
        it 'uses both min and max of range' do
          expect(subject).to eq (3..6)
        end
      end
    end
  end

  describe '.each_phrase' do
    context 'argument length of 1' do
      let(:test_text)       { 'This gives 6 of length 1' }
      let(:expected_yields) { ["this", "gives", "6", "of", "length", "1"] }
      specify { expect { |b| pc.each_phrase(1, &b) }.to yield_successive_args(*expected_yields) }
    end
    context 'argument length of 3' do
      let(:test_text)       { 'This gives 4 of length 3' }
      let(:expected_yields) { ["this gives 4", "gives 4 of", "4 of length", "of length 3"] }
      specify { expect { |b| pc.each_phrase(3, &b) }.to yield_successive_args(*expected_yields) }
    end
  end

  describe '#perform' do
    let(:test_text) { 'This phrase has some text then repeats phrase has some text' }

    describe 'each_phrase' do
      context 'given a range of 3..6' do
        let(:options)   { { min_phrase_length: 3, max_phrase_length: 6 } }
        it 'calls each_phrase with each in range' do
          pc.should_receive(:each_phrase).with(3).ordered
          pc.should_receive(:each_phrase).with(4).ordered
          pc.should_receive(:each_phrase).with(5).ordered
          pc.should_receive(:each_phrase).with(6).ordered

          pc.perform
        end
      end
    end

    describe 'phrases[3]' do
      let(:options)       { { min_phrase_length: 3 } }
      let(:expected_keys) { ['this phrase has', 'phrase has some', 'has some text', 'some text then', 'text then repeats', 'then repeats phrase', 'repeats phrase has'] }
      before              { pc.perform }
      subject             { pc.phrases[3] }

      it 'contains all possible 3 word phrases as keys' do
        expect(subject.keys).to match_array expected_keys
      end

      describe 'value' do
        context 'for phrases that do not occur' do
          subject { pc.phrases[3]['not in string'] }
          it { should eq 0 }
        end

        context 'for phrases occurring once' do
          subject { pc.phrases[3]['this phrase has'] }
          it { should eq 1 }
        end

        context 'for phrases occurring twice' do
          subject { pc.phrases[3]['phrase has some'] }
          it { should eq 2 }
        end
      end
    end
  end
end