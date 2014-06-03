FactoryGirl.define do
  factory :score do
    player { create(:player) }
    music  { create(:music) }
    difficulty Difficulty::MEDIUM
  end
end
