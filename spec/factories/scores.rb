# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :score do
    id ""
    player nil
    music nil
    difficulty 1
    latest_record nil
  end
end
