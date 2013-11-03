require 'spec_helper'

describe Music do
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
          ver = Version.find_by_name('colette')
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
