require 'spec_helper'
require 'tempfile'

describe 'music:load' do
  include_context 'rake'

  its(:prerequisites) { should include('environment') }

  it 'fails when no files given' do
    expect { subject.invoke }.to raise_error
  end

  it 'adds music data to the database' do
    Tempfile.open('rfx2') do |file|
      file.puts('[{"index":"ま","name":"回レ！雪月花","artist":"歌組雪月花","bpm":160,"bsc_lv":4,"bsc_notes":117,"med_lv":6,"med_notes":234,"hrd_lv":10,"hrd_notes":468,"version":"colette All Seasons"},{"index":"あ","name":"愛のかたち 幸せのかたち","artist":"あさき","bpm":238,"bsc_lv":4,"bsc_notes":135,"med_lv":6,"med_notes":189,"hrd_lv":9,"hrd_notes":446,"version":"colette All Seasons"},{"index":"さ","name":"ソ.レ.ミ.ファ.ソーダ","artist":"AKOCHIP ft. nc","bpm":158,"bsc_lv":3,"bsc_notes":106,"med_lv":5,"med_notes":232,"hrd_lv":8,"hrd_notes":343,"version":"colette All Seasons"}]')
      file.flush # force to write
      ENV['music_data'] = file.path
      subject.invoke
      ENV.delete('music_data')
      expect(Music.count).to eq 3
      musics = Music.all
      m = musics[0]
      expect(m.index).to eq 'ま'
      expect(m.name).to eq '回レ！雪月花'
      expect(m.basic_lv).to eq 4
      expect(m.medium_lv).to eq 6
      expect(m.hard_lv).to eq 10
      expect(m.version).to eq Version.find_by(name: 'colette All Seasons')
      m = musics[1]
      expect(m.index).to eq 'あ'
      expect(m.name).to eq '愛のかたち 幸せのかたち'
      expect(m.basic_lv).to eq 4
      expect(m.medium_lv).to eq 6
      expect(m.hard_lv).to eq 9
      expect(m.version).to eq Version.find_by(name: 'colette All Seasons')
    end
  end
end
