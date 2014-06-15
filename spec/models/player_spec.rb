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
      let(:score_data) do
        [{
          name: @music.name,
          scores: {
            Difficulty::MEDIUM => { achievement: 90.0, miss_count: 3 }
          }
        }]
      end

      it 'marks as "updated"' do
        expect { player.check_updates(score_data) }
          .to change { score_data[0][:scores][Difficulty::MEDIUM][:is_achievement_updated] }
          .to :true
      end
    end

    context 'if there is an update for miss count' do
      let(:score_data) do
        [{
          name: @music.name,
          scores: {
            Difficulty::MEDIUM => { achievement: 80.0, miss_count: 1 }
          }
        }]
      end

      it 'marks as "updated"' do
        expect { player.check_updates(score_data) }
          .to change { score_data[0][:scores][Difficulty::MEDIUM][:is_miss_count_updated] }
          .to :true
      end
    end

    context 'if there are updates for achievement rate and miss count' do
      let(:score_data) do
        [{
          name: @music.name,
          scores: {
            Difficulty::MEDIUM => { achievement: 90.0, miss_count: 1 }
          }
        }]
      end

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

  describe '#latest_score' do
    let(:music) { create(:music) }
    let(:difficulty) { Difficulty::MEDIUM }
    before do
      player.scores.create(
        music: music,
        difficulty: Difficulty::BASIC,
        achievement: 98.0,
        miss_count: 0
      )
      player.scores.create(
        music: music,
        difficulty: Difficulty::MEDIUM,
        achievement: 95.0,
        miss_count: 0
      )
      player.scores.create(
        music: music,
        difficulty: Difficulty::HARD,
        achievement: 94.5,
        miss_count: 1
      )
      player.scores.create(
        music: music,
        difficulty: Difficulty::HARD,
        achievement: 95.5,
        miss_count: 1
      )
    end

    describe 'with 1 parameter' do
      subject { player.latest_score(music) }

      it 'returns a hash' do
        expect(subject).to be_instance_of Hash
      end

      it 'returns a hash with 4 items' do
        expect(subject).to have(4).items
      end

      it 'returns a hash whose keys are difficulties' do
        expect(subject.keys).to include(*Difficulty::DIFFICULTIES)
      end

      it 'returns the latest score data' do
        expect(subject[Difficulty::BASIC].music).to eq music
        expect(subject[Difficulty::BASIC].difficulty).to eq Difficulty::BASIC
        expect(subject[Difficulty::BASIC].achievement).to eq 98.0
        expect(subject[Difficulty::BASIC].miss_count).to eq 0
        expect(subject[Difficulty::MEDIUM].music).to eq music
        expect(subject[Difficulty::MEDIUM].difficulty).to eq Difficulty::MEDIUM
        expect(subject[Difficulty::MEDIUM].achievement).to eq 95.0
        expect(subject[Difficulty::MEDIUM].miss_count).to eq 0
        expect(subject[Difficulty::HARD].music).to eq music
        expect(subject[Difficulty::HARD].difficulty).to eq Difficulty::HARD
        expect(subject[Difficulty::HARD].achievement).to eq 95.5
        expect(subject[Difficulty::HARD].miss_count).to eq 1
      end
    end

    describe 'with 2 parameter' do
      subject { player.latest_score(music, difficulty) }

      it 'returns an instance of Score class' do
        expect(subject).to be_instance_of Score
      end

      it 'returns the latest score data' do
        expect(subject.music).to eq music
        expect(subject.difficulty).to eq difficulty
        expect(subject.achievement).to eq 95.0
        expect(subject.miss_count).to eq 0
      end
    end
  end

  describe '#latest_scores' do
    let(:player) { create(:player) }
    before do
      @musics = create_list(:music, 5)
    end

    describe 'without compaction' do
      subject { player.latest_scores(false) }

      context 'if the player has any scores' do
        before do
          @musics.each do |music|
            player.scores << create(:score,
              player: player, music: music,
              difficulty: Difficulty::BASIC, achievement: 98.0, miss_count: 0)
            player.scores << create(:score,
              player: player, music: music,
              difficulty: Difficulty::HARD, achievement: 90.0, miss_count: 2)
          end
          player.scores << create(:score,
            player: player, music: @musics[0],
            difficulty: Difficulty::MEDIUM, achievement: 95.0, miss_count: 1)
        end
        it 'returns a hash' do
          expect(subject).to be_instance_of Hash
        end

        it 'returns a hash which has (Music count) items' do
          expect(subject.size).to eq Music.count
        end

        it 'returns a hash with score data' do
          @musics.each do |music|
            expect(subject[music][Difficulty::BASIC].achievement).to eq 98.0
            expect(subject[music][Difficulty::BASIC].miss_count).to eq 0
            expect(subject[music][Difficulty::HARD].achievement).to eq 90.0
            expect(subject[music][Difficulty::HARD].miss_count).to eq 2
          end
        end

        it 'returns a hash which has an entry of not played difficulty' do
          @musics.each do |music|
            expect(subject[music]).to have_key(Difficulty::MEDIUM)
          end
        end
      end

      context 'if the player has no scores' do
        it 'returns a hash' do
          expect(subject).to be_instance_of Hash
        end

        it 'returns a hash whose player records are empty' do
          expect(subject.values.all? { |s| s.values.all?(&:nil?) }).to be_true
        end
      end
    end

    describe 'with compaction' do
      subject { player.latest_scores(true) }
      context 'if the player has any scores' do
        before do
          @musics.each do |music|
            player.scores << create(:score,
              player: player, music: music,
              difficulty: Difficulty::BASIC, achievement: 98.0, miss_count: 0)
            player.scores << create(:score,
              player: player, music: music,
              difficulty: Difficulty::HARD, achievement: 90.0, miss_count: 2)
          end
          player.scores << create(:score,
            player: player, music: @musics[0],
            difficulty: Difficulty::MEDIUM, achievement: 95.0, miss_count: 1)
        end
        it 'returns a hash' do
          expect(subject).to be_instance_of Hash
        end

        it 'returns a hash which has (Music count) items' do
          expect(subject.size).to eq Music.count
        end

        it 'returns a hash with score data' do
          @musics.each do |music|
            expect(subject[music][Difficulty::BASIC].achievement).to eq 98.0
            expect(subject[music][Difficulty::BASIC].miss_count).to eq 0
            expect(subject[music][Difficulty::HARD].achievement).to eq 90.0
            expect(subject[music][Difficulty::HARD].miss_count).to eq 2
          end
        end

        it 'returns a hash which does not have an entry of not played difficulty' do
          @musics.drop(1).each do |music|
            expect(subject[music]).not_to have_key(Difficulty::MEDIUM)
          end
        end
      end

      context 'if the player has no scores' do
        it 'returns a hash' do
          expect(subject).to be_instance_of Hash
        end

        it 'returns a hash which has (Music count) items' do
          expect(subject.size).to eq Music.count
        end

        it 'returns a hash whose values are empty' do
          expect(subject.all? { |_, v| v.empty? }).to be_true
        end
      end
    end
  end
end
