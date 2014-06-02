require 'spec_helper'

describe Difficulty do
  describe '.from_int' do
    context 'with valid parameter' do
      it 'returns difficulty value' do
        expect(Difficulty.from_int(0)).to eq Difficulty::BASIC
        expect(Difficulty.from_int(1)).to eq Difficulty::MEDIUM
        expect(Difficulty.from_int(2)).to eq Difficulty::HARD
        expect(Difficulty.from_int(3)).to eq Difficulty::SPECIAL
      end
    end
  end

  describe '#more_difficult_than?' do
    let(:difficulty) { Difficulty::MEDIUM }

    context 'with easier value' do
      it 'returns true' do
        expect(difficulty.more_difficult_than? Difficulty::BASIC).to be_true
      end
    end

    context 'with more difficult value' do
      it 'returns false' do
        expect(difficulty.more_difficult_than? Difficulty::HARD).to be_false
        expect(difficulty.more_difficult_than? Difficulty::SPECIAL).to be_false
      end
    end

    context 'with the same value' do
      it 'returns false' do
        expect(difficulty.more_difficult_than? Difficulty::MEDIUM).to be_false
      end
    end
  end

  describe '#easier_than?' do
    let(:difficulty) { Difficulty::MEDIUM }

    context 'with easier value' do
      it 'returns false' do
        expect(difficulty.easier_than? Difficulty::BASIC).to be_false
      end
    end

    context 'with more difficult value' do
      it 'returns true' do
        expect(difficulty.easier_than? Difficulty::HARD).to be_true
        expect(difficulty.easier_than? Difficulty::SPECIAL).to be_true
      end
    end

    context 'with the same value' do
      it 'returns false' do
        expect(difficulty.easier_than? Difficulty::MEDIUM).to be_false
      end
    end
  end
end
