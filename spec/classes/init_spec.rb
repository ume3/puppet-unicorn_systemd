require 'spec_helper'
describe 'unicorn_systemd' do

  let(:params) do
    {
      working_directory: '/srv',
    }
  end

  context 'with default values for all parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_class('unicorn_systemd') }
  end
end
