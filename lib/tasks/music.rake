require 'json'

namespace :music do
  desc 'Load musics'
  task :load => :environment do
    filepath = ENV['music_data']
    raise 'No input file. Specify `music_data`.' if !filepath || filepath.empty?
    start_time = Time.now
    open(filepath, 'r:utf-8') do |io|
      json = JSON.load(io)
      raise 'Empty file loaded, or failed to load JSON.' unless json
      Music.transaction do
        json.each do |m|
          ver = Version.find_by(name: m['version'])
          raise "Version not found: #{m['version']}" unless ver
          music = Music.create(
            index: m['index'],
            name: m['name'],
            basic_lv: m['bsc_lv'],
            medium_lv: m['med_lv'],
            hard_lv: m['hrd_lv'],
            added_at: start_time
          )
          music.version = ver
          music.save!
        end
      end
    end
  end
end
