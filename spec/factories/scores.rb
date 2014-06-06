FactoryGirl.define do
  factory :score do
    player { create(:player) }
    music  { create(:music) }
    achievement 90.0
    miss_count 2
    difficulty Difficulty::MEDIUM
  end
end
