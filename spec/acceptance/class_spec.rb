require 'spec_helper_acceptance'

describe 'unicorn class' do
  let(:manifest) do
    <<-'EOS'
      $pkgs = $osfamily ? {
        'RedHat' => ['rubygems', 'ruby-devel', 'gcc', 'make'],
        'Debian' => ['build-essential', 'ruby', 'ruby-dev'],
      }

      package {
        $pkgs:
          ensure => installed,
          before => Package['unicorn'];

        'rack':
          ensure   => '1.6.5',
          provider => gem;

        'unicorn':
          ensure   => installed,
          provider => gem;
      }

      file {
        '/srv/sample.conf.rb':
          content => 'pid "/var/run/unicorn.pid"';

        '/srv/sample.ru':
          content => 'run lambda { |env| [200, {"Content-Type" => "text/plain"}, ["ppid:#{Process.ppid}\n"]] }';
      }

      class { 'unicorn_systemd':
        user              => 'root',
        group             => 'root',
        working_directory => '/srv',
        pidfile           => '/var/run/unicorn.pid',
        environment       => {
          'RAILS_ENV'  => 'acceptance',
          'UNICORN_RB' => 'sample.conf.rb',
        },
        exec_start        => '/usr/local/bin/unicorn -E $RAILS_ENV -c $UNICORN_RB sample.ru',
        require           => [
          File['/srv/sample.conf.rb'],
          File['/srv/sample.ru'],
          Package['unicorn'],
        ],
      }
    EOS
  end

  it 'works without errors' do
    result = apply_manifest(manifest, acceptable_exit_codes: [0, 2], catch_failures: true)
    expect(result.exit_code).not_to eq 4
    expect(result.exit_code).not_to eq 6
  end

  it 'runs a second time without changes' do
    result = apply_manifest(manifest)
    expect(result.exit_code).to eq 0
  end

  ['rubygems', 'ruby-devel', 'make'].each do |pkg|
    describe package(pkg), if: os[:family] == 'redhat' do
      it { is_expected.to be_installed }
    end
  end

  ['build-essential', 'ruby', 'ruby-dev'].each do |pkg|
    describe package(pkg), if: os[:family] == 'debian' do
      it { is_expected.to be_installed }
    end
  end

  describe package('rubygems-update'), if: os[:family] == 'debian' do
    it { is_expected.to be_installed.by('gem') }
  end

  describe package('unicorn') do
    it { is_expected.to be_installed.by('gem') }
  end

  describe file('/srv/sample.conf.rb') do
    it { is_expected.to be_file }
  end

  describe file('/srv/sample.ru') do
    it { is_expected.to be_file }
  end

  describe file('/etc/systemd/system/unicorn.service') do
    it { is_expected.to be_file }
    it { is_expected.to be_owned_by 'root' }
    it { is_expected.to be_grouped_into 'root' }
    its(:content) { is_expected.to match %r{^User=root$} }
    its(:content) { is_expected.to match %r{^Group=root$} }
    its(:content) { is_expected.to match %r{^WorkingDirectory=/srv$} }
    its(:content) { is_expected.to match %r{^PIDFile=/var/run/unicorn.pid$} }
    its(:content) { is_expected.to match %r{^ExecStart=/usr/local/bin/unicorn -E \$RAILS_ENV -c \$UNICORN_RB sample.ru$} }
    its(:content) { is_expected.to match %r{^Environment="RAILS_ENV=acceptance"$} }
    its(:content) { is_expected.to match %r{^Environment="UNICORN_RB=sample.conf.rb"$} }
  end

  describe service('unicorn') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end
end
