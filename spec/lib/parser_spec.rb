require 'spec_helper'

describe Parser::Colette do
  describe '#parse_profile' do
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

  describe '#parse_music' do
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

