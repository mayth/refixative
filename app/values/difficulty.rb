class Difficulty
  include Comparable

  AVAILABLE = %w(BASIC MEDIUM HARD SPECIAL)

  def self.from_int(n)
    new(AVAILABLE[n - 1])
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
    fail ArgumentError, 'invalid value as difficulty' unless AVAILABLE.include?(v)
    @str = v
  end

  def to_s
    @str
  end

  def to_i
    AVAILABLE.index(@str) + 1
  end

  def more_difficult_than?(other)
    self > other
  end

  def easier_than?(other)
    self < other
  end

  def <=>(other)
    self.to_i <=> other.to_i
  end

  def hash
    @str.hash
  end

  def eql?(other)
    self.to_s == other.to_s
  end

  module Constant
    BASIC = Difficulty.new('BASIC').freeze
    MEDIUM = Difficulty.new('MEDIUM').freeze
    HARD = Difficulty.new('HARD').freeze
    SPECIAL = Difficulty.new('SPECIAL').freeze
  end

  include Constant
end