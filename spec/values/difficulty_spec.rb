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

  describe '#initialize' do
    context 'with valid parameter' do
      context 'which is String' do
        it 'initializes a new instance' do
          x = Difficulty.new('BASIC')
          expect(x).to be_instance_of Difficulty
          x = Difficulty.new('basic')
          expect(x).to be_instance_of Difficulty
        end
      end

      context 'which is Symbol' do
        it 'initializes a new instance' do
          x = Difficulty.new(:BASIC)
          expect(x).to be_instance_of Difficulty
          x = Difficulty.new(:basic)
          expect(x).to be_instance_of Difficulty
        end
      end
    end

    context 'with invalid parameter' do
      context 'which is not String nor Symbol' do
        it 'fails with ArgumentError' do
          expect { Difficulty.new(3939) }.to raise_error ArgumentError
        end
      end

      context 'which is nil' do
        it 'fails with ArgumentError' do
          expect { Difficulty.new(nil) }.to raise_error ArgumentError
        end
      end

      context 'which is String or Symbol but it is not valid as difficulty' do
        it 'fails with ArgumentError' do
          expect { Difficulty.new('Another') }.to raise_error ArgumentError
          expect { Difficulty.new(:EXPERT) }.to raise_error ArgumentError
        end
      end
    end
  end

  describe '#to_s' do
    let(:difficulty) { Difficulty::MEDIUM }
    subject { difficulty.to_s }
    it 'returns String instance' do
      expect(subject).to be_kind_of String
    end
  end

  describe '#to_i' do
    let(:difficulty) { Difficulty::MEDIUM }
    subject { difficulty.to_i }
    it 'returns Integer instance' do
      expect(subject).to be_kind_of Integer
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
