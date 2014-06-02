require 'spec_helper'

describe Difficulty do
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
