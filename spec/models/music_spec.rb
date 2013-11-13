require 'spec_helper'

describe Music do
  describe 'create' do
    before do
      @ver = Version.find_by_name('REFLEC BEAT')
      Music.create(
        name: "L'erisia",
        basic_lv: 4,
        medium_lv: 7,
        hard_lv: 10,
        version: @ver,
        added_at: @ver.released_at)
      @music = Music.find_by_name("L'erisia")
    end
    after do
      Music.delete_all
    end

    subject { @music }
    context 'if the model has been created successfully' do
      it { should_not be_nil }
      its(:name) { should eq("L'erisia") }
      its(:basic_lv) { should eq(4) }
      its(:medium_lv) { should eq(7) }
      its(:hard_lv) { should eq(10) }
      its(:version) { should eq(@ver) }
      it 'added_at' do
        @music.added_at.strftime('%Y-%m-%d').should eq(@ver.released_at.strftime('%Y-%m-%d'))
      end
    end
  end
  describe '::add_musics' do
    context 'if there are no records' do
      before do
        Music.delete_all
      end
      context 'when given empty array' do
        before do
          Music.add_musics []
        end
        it 'should be still empty' do
          Music.should_not be_any
        end
      end
      context 'when given array which has 3 items' do
        before do
          t = Time.now
          ver = Version.last
          Music.add_musics([
            { name: 'abc', basic_lv: 3, medium_lv: 5, hard_lv: 9, version: ver, added_at: t },
            { name: 'def', basic_lv: 4, medium_lv: 6, hard_lv: 10, version: ver, added_at: t },
            { name: 'ghi', basic_lv: 5, medium_lv: 7, hard_lv: 11, version: ver, added_at: t }
          ])
        end
        it 'should not be empty' do
          Music.should be_any
        end
        it 'should have 3 items' do
          Music.should have(3).items
        end
      end
    end
  end
end
