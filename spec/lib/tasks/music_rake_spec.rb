require 'spec_helper'

describe 'music:load' do
  include_context 'rake'

  its(:prerequisites) { should include('environment') }

  it 'fails when no files given' do
    expect { subject.invoke }.to raise_error
  end
end
