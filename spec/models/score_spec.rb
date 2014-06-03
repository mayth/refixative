require 'spec_helper'

describe Score do
  let(:score) { create(:score) }
  describe '#difficulty' do
    subject { score.difficulty }
    it 'returns Difficulty value' do
      expect(subject).to be_instance_of Difficulty
    end
  end

  describe '#difficulty=' do
    context 'with nil' do
      it 'fails with an error' do
        expect { score.difficulty = nil }.to raise_error
      end
    end
    context 'with Difficulty' do
      it 'updates #difficulty' do
        expect { score.difficulty = Difficulty::SPECIAL }
          .to change { score.difficulty }.to Difficulty::SPECIAL
      end
      it 'still be valid' do
        expect(score).to be_valid
        expect { score.difficulty = Difficulty::SPECIAL }
          .not_to change { score.valid? }
      end
    end

    context 'with String' do
      context 'which is valid as a difficulty value' do
        it 'updates #difficulty' do
          expect { score.difficulty = 'special' }
            .to change { score.difficulty }.to Difficulty::SPECIAL
        end
        it 'still be valid' do
          expect(score).to be_valid
          expect { score.difficulty = 'special' }
            .not_to change { score.valid? }
        end
      end

      context 'which is invalid as a difficulty value' do
        it 'fails with an error' do
          expect { score.difficulty = 'daily lunch special' }.to raise_error
        end
      end
    end

    context 'with Integer' do
      context 'which is valid as a difficulty value' do
        it 'updates #difficulty' do
          expect { score.difficulty = 4 }
            .to change { score.difficulty }.to Difficulty.from_int(4)
        end
        it 'still be valid' do
          expect(score).to be_valid
          expect { score.difficulty = 4 }
            .not_to change { score.valid? }
        end
      end

      context 'which is invalid as a difficulty value' do
        it 'fails with an error' do
          expect { score.difficulty = 9999 }.to raise_error
        end
      end
    end
  end
end
