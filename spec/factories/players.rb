# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :player do
    id ""
    name "MyString"
    pseudonym "MyString"
    comment "MyString"
    team nil
    play_count 1
    stamp 1
    onigiri 1
    last_play_date "2014-01-09 15:09:55"
    last_play_shop "MyString"
  end
end
