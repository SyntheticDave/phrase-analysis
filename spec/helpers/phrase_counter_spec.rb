require 'spec_helper'
require './app/helpers/phrase_counter'

describe PhraseCounter do
  let(:test_text) { '' }
  let(:options)   { { min_length: 3, max_length: 3 } }
  let(:pc)        { PhraseCounter.new(test_text, options) }

  describe '#phrase_options' do
    describe 'phrase length' do
      subject { pc.phrase_options(options)[:length_range] }
      context 'only min phrase length passed' do
        let(:options) { { min_length: 2 } }
        it 'uses min as both min and max of range' do
          expect(subject).to eq(2..2)
        end
      end
      context 'only max phrase length passed' do
        let(:options) { { max_length: 6 } }
        it 'uses max as both min and max of range' do
          expect(subject).to eq(6..6)
        end
      end
      context 'both min and max passed' do
        let(:options) { { min_length: 3, max_length: 6 } }
        it 'uses both min and max of range' do
          expect(subject).to eq(3..6)
        end
      end
    end
  end

  describe '.each_phrase' do
    context 'argument length of 1' do
      let(:test_text)       { 'this gives 6 of length 1' }
      let(:expected_yields) { test_text.split(/\s/) }
      specify { expect { |b| pc.each_phrase(1, &b) }.to yield_successive_args(*expected_yields) }
    end
    context 'argument length of 3' do
      let(:test_text)       { 'this gives 4 of length 3' }
      let(:expected_yields) do
        ['this gives 4', 'gives 4 of',
         '4 of length', 'of length 3']
      end
      specify { expect { |b| pc.each_phrase(3, &b) }.to yield_successive_args(*expected_yields) }
    end
  end

  describe '#perform' do
    let(:test_text) { 'This phrase has some text then repeats phrase has some text' }

    describe 'each_phrase' do
      context 'given a range of 3..6' do
        let(:options)   { { min_length: 3, max_length: 6 } }
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
      let(:options)       { { min_length: 3 } }
      let(:expected_keys) do
        ['this phrase has', 'phrase has some', 'has some text',
         'some text then', 'text then repeats', 'then repeats phrase',
         'repeats phrase has'
        ]
      end
      before              { pc.perform }
      subject             { pc.phrases[3] }

      it 'contains all possible 3 word phrases as keys' do
        expect(subject.keys).to match_array expected_keys
      end

      describe 'value' do
        context 'for phrases that do not occur' do
          subject { pc.phrases[3]['not in string'] }
          it { should be_nil }
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

  describe '#word_count' do
    context 'given a string of 5 words' do
      let(:test_text) { '1 2 3 4 5' }
      subject         { pc.word_count }
      it { should eq 5 }
    end
  end

  describe '#running_phrase_check' do
    let(:check_phrase)              { 'a test' }

    before do
      pc.instance_variable_set(:@phrases, phrases)
    end

    context 'for a phrase that has been found before' do
      let(:phrases)                   { { 2 => { check_phrase => 1 } } }
      let(:expected_running_phrases)  { [check_phrase] }
      before { pc.running_phrase_check(check_phrase) }

      it 'adds the phrase to @running_phrases' do
        expect(pc.instance_variable_get(:@running_phrases)).to match_array expected_running_phrases
      end
    end

    context 'for a phrase that has not been found before' do
      let(:phrases) { { 2 => Hash.new(0)  } }

      context 'and no running phrases have been found' do
        before do
          pc.instance_variable_set(:@running_phrases, ['bogus phrase'])
          pc.running_phrase_check(check_phrase)
        end

        it 'clears running phrases' do
          expect(pc.instance_variable_get(:@running_phrases)).to be_empty
        end
      end

      context 'and a running phrase has been found' do
        before do
          pc.instance_variable_set(:@running_phrases, ['this is', 'is a'])
        end

        it 'calls #record_longer_phrase' do
          pc.should_receive(:record_longer_phrase)
          pc.running_phrase_check(check_phrase)
        end

        it 'clears running phrases' do
          pc.running_phrase_check(check_phrase)
          expect(pc.instance_variable_get(:@running_phrases)).to be_empty
        end
      end
    end
  end

  describe '#record_longer_phrase' do
    let(:initial_phrases)         { { } }
    let(:compiled_phrase_length)  { 4 }
    let(:compiled_phrase)         { 'some kind of test' }

    before do
      pc.phrases =  initial_phrases
      pc.stub(:compile_phrase) { compiled_phrase }
    end

    describe '@phrases' do
      it 'initialises the correct length in @phrases' do
        pc.record_longer_phrase
        phrases = pc.instance_variable_get(:@phrases)
        expect(phrases).to have_key(compiled_phrase_length)
      end
    end

    describe 'new phrase' do
      context 'that has not been found before' do
        let(:initial_phrases) { { 4 => Hash.new(0) } }
        it 'records two occurrances of the new phrase' do
          expect { pc.record_longer_phrase }.to change{pc.phrases[compiled_phrase_length][compiled_phrase]}.by(2)
        end
      end

      context 'that has been found before' do
        let(:initial_phrases) { { 4 => { 'some kind of test' => 4 } } }
        it 'records one new occurrance of the phrase' do
          expect { pc.record_longer_phrase }.to change{pc.phrases[compiled_phrase_length][compiled_phrase]}.by(1)
        end
      end
    end
  end

  describe '#compile_phrase' do
    let(:initial_running_phrases) { ['some kind', 'kind of', 'of sample'] }
    let(:final_running_phrases) { ['some kind', 'kind of', 'of sample'] }
    before do
      pc.instance_variable_set(:@running_phrases, initial_running_phrases)
    end

    describe '@running_phrases' do
      before { pc.compile_phrase }
      it 'does not alter @running_phrases' do
        expect(pc.instance_variable_get(:@running_phrases)).to match_array final_running_phrases
      end
    end

    describe 'compiled phrase' do
      it 'returns the result phrase from its components' do
        expect(pc.compile_phrase).to eq 'some kind of sample'
      end
    end
  end

  describe '#remove_component_phrases' do
    let(:options) { { min_length: 2 } }
    before do
      pc.phrases = { 2 => { 'some kind' => 3, 'kind of' => 4, 'of sample' => 3 }, 3 => { 'some kind of' => 3, 'kind of sample' => 1 }, 4 => { 'I am completely unrelated' => 2 } }
    end

    it 'calls remove_component_phrase from the longest phrase' do
      pc.should_receive(:remove_component_phrase).with('I am completely unrelated', 2).ordered
      pc.should_receive(:remove_component_phrase).with('some kind of', 3).ordered
      pc.remove_component_phrases
    end

    it 'ignores phrases with only 1 occurrence' do
      pc.should_not_receive(:remove_component_phrase).with('kind of sample', 1)
      pc.remove_component_phrases
    end

    it 'ignores phrases of min length' do
      pc.should_not_receive(:remove_component_phrase).with(/^(some kind|kind of|of sample)$/, an_instance_of(Fixnum))
      pc.remove_component_phrases
    end
  end

  describe '#remove_conponent_phrase' do
    let(:component_phrases) { { 2 => { 'some kind' => 3, 'kind of' => 4, 'of sample' => 3 } } }

    before do
      pc.phrases = component_phrases
    end
    context 'argument phrase' do
      let(:options)   { { min_length: 2 } }

      context 'is the shortest found phrase' do
        let(:phrase_to_remove) { 'some kind' }

        it 'does not alter phrases' do
          expect{ pc.remove_component_phrase(phrase_to_remove, 2) }.to_not change{ pc.phrases }
        end
      end

      context 'is not the shortest phrase found' do
        context 'but does not have any component phrases' do
          let(:phrase_to_remove) { 'this is a' }

          it 'does not alter phrases' do
            expect{ pc.remove_component_phrase(phrase_to_remove, 2) }.to_not change{ pc.phrases }
          end
        end

        context 'and has component phrases to remove' do
          let(:phrase_to_remove)      { 'some kind of' }

          context 'with less occurrences than were found of the component phrase' do
            let(:occurrences_to_remove) { 2 }

            it 'removes occurrances of the component phrase "some kind"' do
              expect{ pc.remove_component_phrase(phrase_to_remove, occurrences_to_remove) }.to change{ pc.phrases[2]['some kind'] }.by(-occurrences_to_remove)
            end

            it 'removes occurrences of the component phrase "kind of"' do
              expect{ pc.remove_component_phrase(phrase_to_remove, occurrences_to_remove) }.to change{ pc.phrases[2]['kind of'] }.by(-occurrences_to_remove)
            end

            it 'does not remove occurrences of phrases that are not components of the argument' do
              expect{ pc.remove_component_phrase(phrase_to_remove, occurrences_to_remove) }.to_not change{ pc.phrases[2]['of sample'] }
            end
          end

          context 'with equal occurrences found of component phrase' do
            let(:occurrences_to_remove) { 3 }

            it 'removes all occurances and the key of the component phrase' do
              pc.remove_component_phrase(phrase_to_remove, occurrences_to_remove)
              expect(pc.phrases[2]).to_not include 'some kind'
            end
          end
        end
      end
    end
  end
end
