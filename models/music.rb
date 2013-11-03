class Music < ActiveRecord::Base
  belongs_to :score
  belongs_to :version
  validates_presence_of :name
  validates_presence_of :basic_lv
  validates_presence_of :medium_lv
  validates_presence_of :hard_lv
  validates_presence_of :added_at

  def self.add_musics(musics, ver = nil)
    time = Time.now
    ver ||= Version.last
    raise 'No version specified.' unless ver
    transaction do
      musics.each do |m|
        next if Music.find_by_name(m[:name])
        Music.new(
          name: m[:name],
          basic_lv: m[:basic_lv],
          medium_lv: m[:medium_lv],
          hard_lv: m[:hard_lv],
          version: ver,
          added_at: time).save
      end
    end
  end
end
