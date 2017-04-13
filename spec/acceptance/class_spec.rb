require 'spec_helper_acceptance'

describe 'unicorn class' do
  let(:manifest) {
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
  }

  it 'should work without errors' do
    result = apply_manifest(manifest, :acceptable_exit_codes => [0, 2], :catch_failures => true)
    expect(result.exit_code).not_to eq 4
    expect(result.exit_code).not_to eq 6
  end

  it 'should run a second time without changes' do
    result = apply_manifest(manifest)
    expect(result.exit_code).to eq 0
  end

  %w(rubygems ruby-devel make).each do |pkg|
    describe package(pkg), if: os[:family] == 'redhat' do
      it { should be_installed }
    end
  end

  %w(build-essential ruby ruby-dev).each do |pkg|
    describe package(pkg), if: os[:family] == 'debian' do
      it { should be_installed }
    end
  end

  describe package('rubygems-update'), if: os[:family] == 'debian' do
    it { should be_installed.by('gem') }
  end

  describe package('unicorn') do
    it { should be_installed.by('gem') }
  end

  describe file('/srv/sample.conf.rb') do
    it { should be_file }
  end

  describe file('/srv/sample.ru') do
    it { should be_file }
  end

  describe file('/etc/systemd/system/unicorn.service') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match /^User=root$/ }
    its(:content) { should match /^Group=root$/ }
    its(:content) { should match %r|^WorkingDirectory=/srv$| }
    its(:content) { should match %r|^PIDFile=/var/run/unicorn.pid$| }
    its(:content) { should match %r|^ExecStart=/usr/local/bin/unicorn -E \$RAILS_ENV -c \$UNICORN_RB sample.ru$| }
    its(:content) { should match /^Environment="RAILS_ENV=acceptance"$/ }
    its(:content) { should match /^Environment="UNICORN_RB=sample.conf.rb"$/ }
  end

  describe service('unicorn') do
    it { should be_enabled }
    it { should be_running }
  end
end
