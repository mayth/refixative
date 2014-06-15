FactoryGirl.define do
  factory :player do
    pid 'RB-1234-5678'
    name 'ＰＬＡＹＥＲ'
    pseudonym '期待の新鋭'
    level 2
    grade '師範代'
    comment '小傘ちゃんかわいい'
    play_count 1
    refle 1550
    total_point 6670
    last_play_datetime { Time.now }
    last_play_place 'ジャムジャムつくば店'
  end
end
