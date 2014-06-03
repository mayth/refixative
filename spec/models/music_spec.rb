require 'spec_helper'

describe Music do
  let(:music) { create(:music) }

  shared_examples 'a getter of level' do
    it 'returns Level instance' do
      expect(subject).to be_instance_of Level
    end
  end

  shared_examples 'a setter of level' do |getter, accepts_nil|
    setter = "#{getter}=".to_sym
    context 'with nil' do
      if accepts_nil
        it "updates ##{getter}" do
          expect { music.send(setter, nil) }
            .to change { music.send(getter) }.to nil
        end
      else
        it 'changes its state to invalid' do
          expect { music.send(setter, nil) }.to change { music.valid? }.to false
        end
      end
    end

    context 'with Level' do
      it "updates ##{getter}" do
        expect { music.send(setter, Level.new(4)) }
          .to change { music.send(getter) }.to Level.new(4)
      end
      it 'still be valid' do
        expect { music.send(setter, Level.new(4)) }.not_to change { music.valid? }
      end
    end

    context 'with String' do
      context 'which is valid as level' do
        it "updates ##{getter}" do
          expect { music.send(setter, '10+') }
            .to change { music.send(getter) }.to Level.from_string('10+')
        end
        it 'still be valid' do
          expect { music.send(setter, '10+') }.not_to change { music.valid? }
        end
      end

      context 'which is invalid as level' do
        it 'fails with an error' do
          expect { music.send(setter, 'pastel') }.to raise_error
        end
      end
    end

    context 'with Integer' do
      context 'which is valid as a level' do
        it "updates ##{getter}" do
          expect { music.send(setter, 11) }
            .to change { music.send(getter) }.to Level.new(11)
        end

        it 'still be valid' do
          expect { music.send(setter, 11) }.not_to change { music.valid? }
        end
      end

      context 'which is invalid as a level' do
        it 'fails with an error' do
          expect { music.send(setter, 3939) }.to raise_error
        end
      end
    end
  end

  describe '#basic_lv' do
    subject { music.basic_lv }
    it_behaves_like 'a getter of level'
  end

  describe '#basic_lv=' do
    it_behaves_like 'a setter of level', :basic_lv, false
  end

  describe '#medium_lv' do
    subject { music.medium_lv }
    it_behaves_like 'a getter of level'
  end

  describe '#medium_lv=' do
    it_behaves_like 'a setter of level', :medium_lv, false
  end

  describe '#hard_lv' do
    subject { music.hard_lv }
    it_behaves_like 'a getter of level'
  end

  describe '#hard_lv=' do
    it_behaves_like 'a setter of level', :hard_lv, false
  end

  describe '#special_lv' do
    subject { music.special_lv }
    it_behaves_like 'a getter of level'
    context 'with nil' do
      let(:music) { create(:music, special_lv: nil) }
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#special_lv=' do
    it_behaves_like 'a setter of level', :special_lv, true
  end
end
