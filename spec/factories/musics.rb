FactoryGirl.define do
  factory :music do
    sequence    (:name) {|n| "music #{n}" }
    basic_lv    Level.new(2)
    medium_lv   Level.new(5)
    hard_lv     Level.new(8)
    special_lv  Level.new(10) # it does not exist actually!!
    added_at    Time.new(2012, 11, 21, 10, 0, 0, '+09:00')
    version     { create(:version, name: 'colette Winter') }
  end
end
