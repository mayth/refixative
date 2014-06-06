require 'spec_helper'

describe Player do
  let(:player) { create(:player) }
  describe '#update_score' do
    before do
      @music = create(:music)
      player.scores.create(
        music: @music,
        difficulty: Difficulty::MEDIUM,
        achievement: 80.0,
        miss_count: 3
      )
    end

    context 'with valid parameters' do
      before do
        @score_data = [{
          name: @music.name,
          scores: {
            Difficulty::MEDIUM => { achievement: 90.0, miss_count: 1 }
          }
        }]
      end

      it 'adds a new score record' do
        expect { player.update_score(@score_data) }
          .to change { player.scores.count }.by(1)
      end

      it 'updates the latest score' do
        current_score = player.scores
          .where(music: @music, difficulty: Difficulty::MEDIUM.to_i)
          .order(created_at: :desc)
          .first
        player.update_score(@score_data)
        new_score = player.scores
          .where(music: @music, difficulty: Difficulty::MEDIUM.to_i)
          .order(created_at: :desc)
          .first
        expect(new_score).not_to eq current_score
      end
    end
  end
end
