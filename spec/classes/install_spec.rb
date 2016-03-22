require 'spec_helper'
describe 'unicorn_systemd::install' do
  context 'with default values for all parameters' do
    let(:params) do
      { working_directory: '/srv' }
    end

    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_class('unicorn_systemd::install') }

    it { should contain_file('/etc/systemd/system/unicorn.socket').with_ensure('present') }
    it { should contain_file('/etc/systemd/system/unicorn@.service').with_ensure('present') }
  end

  context 'with absent' do
    let(:params) do
      {
        working_directory: '/srv',
        ensure: 'absent',
      }
    end

    it { should contain_file('/etc/systemd/system/unicorn.socket').with_ensure('absent') }
    it { should contain_file('/etc/systemd/system/unicorn@.service').with_ensure('absent') }
  end
end
