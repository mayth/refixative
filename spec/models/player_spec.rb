require 'spec_helper'

describe Player do
  let(:player) { create(:player) }

  describe '#check_updates' do
    before do
      @music = create(:music)
      player.scores.create(
        music: @music,
        difficulty: Difficulty::MEDIUM,
        achievement: 80.0,
        miss_count: 3
      )
    end

    context 'if there is an update for achievement rate' do
      let(:score_data) {
        [{
          name: @music.name,
          scores: {
            Difficulty::MEDIUM => { achievement: 90.0, miss_count: 3 }
          }
        }]
      }

      it 'marks as "updated"' do
        expect { player.check_updates(score_data) }
          .to change { score_data[0][:scores][Difficulty::MEDIUM][:is_achievement_updated] }
          .to :true
      end
    end

    context 'if there is an update for miss count' do
      let(:score_data) {
        [{
          name: @music.name,
          scores: {
            Difficulty::MEDIUM => { achievement: 80.0, miss_count: 1 }
          }
        }]
      }

      it 'marks as "updated"' do
        expect { player.check_updates(score_data) }
          .to change { score_data[0][:scores][Difficulty::MEDIUM][:is_miss_count_updated] }
          .to :true
      end
    end

    context 'if there are updates for achievement rate and miss count' do
      let(:score_data) {
        [{
          name: @music.name,
          scores: {
            Difficulty::MEDIUM => { achievement: 90.0, miss_count: 1 }
          }
        }]
      }

      it 'marks as "updated" for achievement rate' do
        expect { player.check_updates(score_data) }
          .to change { score_data[0][:scores][Difficulty::MEDIUM][:is_achievement_updated] }
          .to :true
      end

      it 'marks as "updated" for miss count' do
        expect { player.check_updates(score_data) }
          .to change { score_data[0][:scores][Difficulty::MEDIUM][:is_miss_count_updated] }
          .to :true
      end
    end
  end

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
        current_score = player.scores.order(created_at: :desc)
          .find_by(music: @music, difficulty: Difficulty::MEDIUM.to_i)
        player.update_score(@score_data)
        new_score = player.scores.order(created_at: :desc)
          .find_by(music: @music, difficulty: Difficulty::MEDIUM.to_i)
        expect(new_score).not_to eq current_score
      end

      it 'returns updated score data array' do
        expect(player.update_score(@score_data)).to be_instance_of Array
      end

      it 'returns updated score data' do
        result = player.update_score(@score_data).first
        expect(result.music).to eq @music
        expect(result.difficulty).to eq Difficulty::MEDIUM
        expect(result.achievement).to eq 90.0
        expect(result.miss_count).to eq 1
      end
    end
  end
end
