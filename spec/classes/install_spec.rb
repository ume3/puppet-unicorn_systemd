require 'spec_helper'
describe 'unicorn_systemd::install' do

  let(:params) do
    {
      working_directory: '/srv',
      listen_streams: ['127.0.0.1:8080', '/var/run/unicorn.sock'],
    }
  end

  context 'with default values for all parameters' do
    it { should compile }
    it { should compile.with_all_deps }
    it { should contain_class('unicorn_systemd::install') }
  end
end
