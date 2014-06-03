FactoryGirl.define do
  factory :player do
    pid     'RB-1234-5678'
    name    'ＰＬＡＹＥＲ'
    last_play_datetime { Time.now }
    last_play_place 'ジャムジャムつくば店'
  end
end
