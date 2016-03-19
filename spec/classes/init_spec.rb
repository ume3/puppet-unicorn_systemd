require 'spec_helper'
describe 'unicorn_systemd' do

  context 'with default values for all parameters' do
    it { should contain_class('unicorn_systemd') }
  end
end
