require 'spec_helper'

describe Parser do
  describe '::name_normalize' do

    context 'when given string which has no characters to replace' do
      subject { Parser.name_normalize('abcd') }
      it { should == 'abcd' }
    end

    context 'when given nil' do
      it do
        expect { Parser.name_normalize(nil) }.to raise_error
      end
    end

    context 'when given string which has some characters to replace' do
      subject { Parser.name_normalize("abc  de''f''") }
      it { should == 'abc de"f"' }
    end
  end
end

describe Parser::Colette do
  describe '::parse_profile' do
    context 'when given valid HTML file' do
      before do
        @file = File.open(File.join(__dir__, 'profile.html'))
      end
      after do
        @file.close
      end
      it do
        expect { Parser::Colette.parse_profile(@file) }.not_to raise_error
      end
    end

    context 'when given empty text' do
      it do
        expect { Parser::Colette.parse_profile('') }.to raise_error
      end
    end

    context 'when given broken html' do
      it do
        expect { Parser::Colette.parse_profile('THIS IS NOT HTML TEXT!') }.to raise_error
      end
    end
  end

  describe '::parse_music' do
    context 'when given valid HTML file' do
      before do
        @file = File.open(File.join(__dir__, 'music.html'))
      end
      after do
        @file.close
      end
      it do
        expect { Parser::Colette.parse_music(@file) }.not_to raise_error
      end
    end

    context 'when given empty text' do
      it do
        expect { Parser::Colette.parse_music('') }.to raise_error
      end
    end

    context 'when given broken html' do
      it do
        expect { Parser::Colette.parse_music('THIS IS NOT HTML TEXT!') }.to raise_error
      end
    end
  end
end

