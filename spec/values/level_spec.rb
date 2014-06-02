require 'spec_helper'

describe Level do
  describe '.from_string' do
    context 'with valid as a level value' do
      context 'which is "10+"' do
        it 'returns 11' do
          expect(Level.from_string('10+')).to eq Level.new(11)
        end
      end

      context 'which is ordinal integer value' do
        it 'returns the number represented in the given string' do
          (1..10).each do |i|
            expect(Level.from_string(i.to_s)).to eq Level.new(i)
          end
        end
      end
    end

    context 'with invalid as a level value' do
      it 'fails' do
        expect { Level.from_string('39') }.to raise_error
      end
    end
  end

  describe '#easier_than?' do
    let(:level) { Level.new(5) }

    context 'with more difficult levels' do
      it 'returns true' do
        (6..11).each do |lv|
          expect(level.easier_than? Level.new(lv)).to be_true
        end
      end
    end

    context 'with easier levels' do
      it 'returns false' do
        (1..4).each do |lv|
          expect(level.easier_than? Level.new(lv)).to be_false
        end
      end
    end

    context 'with the same level' do
      it 'returns false' do
        expect(level.easier_than? Level.new(5)).to be_false
      end
    end
  end

  describe '#more_difficult_than?' do
    let(:level) { Level.new(5) }

    context 'with more difficult levels' do
      it 'returns false' do
        (6..11).each do |lv|
          expect(level.more_difficult_than? Level.new(lv)).to be_false
        end
      end
    end

    context 'with easier levels' do
      it 'returns true' do
        (1..4).each do |lv|
          expect(level.more_difficult_than? Level.new(lv)).to be_true
        end
      end
    end

    context 'with the same level' do
      it 'returns false' do
        expect(level.more_difficult_than? Level.new(5)).to be_false
      end
    end
  end
end
