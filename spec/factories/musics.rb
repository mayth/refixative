# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :music do
    id ""
    name "MyString"
    version nil
    basic_lv 1
    medium_lv 1
    hard_lv 1
    added_at "2014-01-09"
    deleted_at "2014-01-09"
  end
end
