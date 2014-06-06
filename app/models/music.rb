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

  Difficulty::DIFFICULTIES.map(&:to_s).map(&:downcase).each do |difficulty|
    var = "#{difficulty}_lv"
    class_eval <<-RUBY
      def #{var}
        @#{var} ||= self[:#{var}] ? Level.new(self[:#{var}]) : nil
      end

      def #{var}=(val)
        if val
          @#{var} = 
            case val
            when Level
              val
            when String
              Level.from_string(val)
            when Integer
              Level.new(val)
            else
              if val.respond_to?(:to_i)
                Level.new(val.to_i)
              elsif val.respond_to?(:to_s)
                Level.from_string(val.to_s)
              else
                fail ArgumentError, 'cannot convert to Level value.'
              end
            end
          self[:#{var}] = @#{var}.to_i
        else
          @#{var} = nil
          self[:#{var}] = nil
        end
        @#{var}
      end
    RUBY
  end
end

