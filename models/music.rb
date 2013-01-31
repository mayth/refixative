class Music < Sequel::Model
  one_to_one :score
  many_to_one :version

  def self.add_musics(new_musics)
    time = Time.now
    ver = Version.find(name: 'colette')
    raise unless ver
    new_musics.each do |m|
      Music.new(
        name: m[:name],
        basic_lv: m[:scores][:basic][:lv],
        medium_lv: m[:scores][:medium][:lv],
        hard_lv: m[:scores][:hard][:lv],
        version: ver,
        added_at: time).save
    end
  end
end
