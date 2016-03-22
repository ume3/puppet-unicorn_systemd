require 'spec_helper'
describe 'unicorn_systemd::service' do

  let(:params) do
    {
      service_ensure: 'running',
      service_enable: true,
    }
  end

  context 'with default values for all parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_class('unicorn_systemd::service') }
  end
end
