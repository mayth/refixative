class Level
  include Comparable

  class << self
    def from_string(lv)
      if lv == '10+'
        Level.new(11)
      else
        Level.new(lv.to_i)
      end
    end
  end

  def initialize(lv)
    case lv
    when Integer
      @lv = lv
    when String
      @lv = self.from_string(lv)
    else
      fail TypeError
    end

    fail ArgumentError, 'out of range' unless (1..11).include?(@lv)
  end

  def to_s
    if @lv == 11
      '10+'
    else
      @lv.to_s
    end
  end

  def to_i
    @lv
  end

  def eql?(other)
    self.to_i == other.to_i
  end

  def hash
    @lv.hash
  end

  def <=>(other)
    self.to_i <=> other.to_i
  end

  def easier_than?(other)
    self < other
  end

  def more_difficult_than?(other)
    self > other
  end
end