class Player < ActiveRecord::Base
  has_many :scores, inverse_of: :player, dependent: :destroy
  belongs_to :team, inverse_of: :players

  structure do
    pid     'RB-1234-5678',
      validates: [
        :presence,
        :uniqueness,
        format: { with: /\ARB-\d{4}-\d{4}\z/ }
      ]
    name    'ＰＬＡＹＥＲ', validates: :presence
    last_play_datetime Time.now
    last_play_place 'ジャムジャムつくば店'

    timestamps
  end

  validates_associated :team
end

