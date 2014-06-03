class Music < ActiveRecord::Base
  has_many :scores, inverse_of: :music, dependent: :restrict_with_error
  belongs_to :version, inverse_of: :musics
  structure do
    name        'ツキミチヌ', validates: :presence
    basic_lv    2, validates: :presence
    medium_lv   5, validates: :presence
    hard_lv     8, validates: :presence
    special_lv  :integer
    added_at    Time.new(2011, 11, 16, 10, 0, 0, '+09:00')
    timestamps
  end

  validates_associated :version

  Difficulty::AVAILABLE.map(&:downcase).each do |difficulty|
    var = "#{difficulty}_lv"
    class_eval <<-RUBY
      def #{var}
        @#{var} ||= Level.new(self[:#{var}])
      end

      def #{var}=(val)
        case val
        when Integer
          @#{var} = Level.new(val)
        when String
          @#{var} = Level.from_string(val)
        when Level
          @#{var} = val
        else
          fail TypeError, 'unexpected value for #{var}'
        end
        self[:#{var}] = @#{var}.to_i
        @#{var}
      end
    RUBY
  end
end

