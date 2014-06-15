class Difficulty
  include Comparable

  AVAILABLES = %w(BASIC MEDIUM HARD SPECIAL).map(&:freeze).freeze
  private_constant :AVAILABLES

  def self.from_int(n)
    fail RangeError, "`n' should be positive integer." unless 0 < n
    new(AVAILABLES[n - 1])
  end

  def initialize(str)
    fail ArgumentError, 'nil is not accepted' unless str
    v = 
      case str
      when String
        str.upcase
      when Symbol
        str.to_s.upcase
      end
    fail ArgumentError, 'invalid value as difficulty' unless AVAILABLES.include?(v)
    @str = v
  end

  def to_s
    @str
  end

  def to_i
    AVAILABLES.index(@str) + 1
  end

  def inspect
    to_s
  end

  def more_difficult_than?(other)
    self > other
  end

  def easier_than?(other)
    self < other
  end

  def <=>(other)
    to_i <=> other.to_i
  end

  def hash
    @str.hash
  end

  def eql?(other)
    to_s == other.to_s
  end

  module Constant
    BASIC = Difficulty.new('BASIC').freeze
    MEDIUM = Difficulty.new('MEDIUM').freeze
    HARD = Difficulty.new('HARD').freeze
    SPECIAL = Difficulty.new('SPECIAL').freeze
    DIFFICULTIES = [BASIC, MEDIUM, HARD, SPECIAL].freeze
  end

  include Constant
end