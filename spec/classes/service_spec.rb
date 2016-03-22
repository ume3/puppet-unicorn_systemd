require 'spec_helper'
describe 'unicorn_systemd::service' do
  context 'with default values for all parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_class('unicorn_systemd::service') }
  end

  context 'with running' do
    it { should contain_service('unicorn.socket').with_ensure('running') }
    it { should contain_service('unicorn@1.service').with_ensure('running') }
    it { should contain_service('unicorn@2.service').with_ensure('running') }
  end

  context 'with stopped' do
    let(:params) do
      { service_ensure: 'stopped' }
    end

    it { should contain_service('unicorn.socket').with_ensure('stopped') }
    it { should contain_service('unicorn@1.service').with_ensure('stopped') }
    it { should contain_service('unicorn@2.service').with_ensure('stopped') }
  end
end
