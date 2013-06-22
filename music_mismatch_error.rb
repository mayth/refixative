#coding: utf-8

class MusicMismatchError < Exception
  def initialize(searching_name, found_name = nil)
    @searching_name = searching_name
    @found_name = found_name
  end
  attr :searching_name, :found_name
end
