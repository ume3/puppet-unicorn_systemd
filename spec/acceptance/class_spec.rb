require 'spec_helper_acceptance'

describe 'unicorn class' do
  let(:manifest) {
    <<-EOS
      if $::osfamily == 'RedHat' {
        package { ['rubygems', 'ruby-devel', 'make']:
          ensure => installed,
          before => Package['unicorn'];
        }
      } elsif $osfamily == 'Debian' {
        package {
          ['build-essential', 'ruby', 'ruby-dev']:
            ensure => installed,
            before => Package['rubygems-update'];

          'rubygems-update':
            ensure          => installed,
            provider        => gem,
            install_options => ['--no-document'],
            before          => Package['unicorn'],
            notify          => Exec['update_rubygems --no-document'];
        }

        exec { 'update_rubygems --no-document':
          path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          refreshonly => true,
        }
      }

      package { ['rack', 'unicorn']:
        ensure          => installed,
        provider        => gem,
        install_options => ['--no-document'],
        before          => Class['unicorn_systemd'];
      }

      file { '/srv/sample.ru':
        ensure  => present,
        content => file('unicorn_systemd/sample.ru'),
        mode    => '0755',
        before  => Class['unicorn_systemd'];
      }

      class { 'unicorn_systemd':
        exec_start        => '/usr/local/bin/unicorn -E $RAILS_ENV /srv/sample.ru',
        environment       => { 'RAILS_ENV' => 'acceptance'},
        working_directory => '/srv',
        service_ensure    => running,
        service_enable    => true,
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

  context 'RedHat', if: os[:family] == 'redhat' do
    %w(rubygems ruby-devel make).each do |pkg|
      describe package(pkg) do
        it { should be_installed }
      end
    end
  end

  context 'Debian', if: os[:family] == 'debian' do
    %w(build-essential ruby ruby-dev).each do |pkg|
      describe package(pkg) do
        it { should be_installed }
      end
    end

    describe package('rubygems-update') do
      it { should be_installed.by('gem')}
    end
  end

  describe package('unicorn') do
    it { should be_installed.by('gem')}
  end

  describe file('/srv/sample.ru') do
    it { should be_file }
    it { should be_mode 755 }
  end

  describe file('/etc/systemd/system/unicorn.socket') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
    its(:content) { should match %r|^ListenStream = 127.0.0.1:8080$| }
    its(:content) { should match %r|^ListenStream = /var/run/unicorn.sock$| }
  end

  describe file('/etc/systemd/system/unicorn@.service') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
    its(:content) { should match /^User = nobody$/ }
    its(:content) { should match %r|^WorkingDirectory = /srv$| }
    its(:content) { should match %r|^ExecStart = /usr/local/bin/unicorn -E \$RAILS_ENV /srv/sample.ru$| }
    its(:content) { should match /^Environment = "RAILS_ENV=acceptance"$/ }
  end

  describe service('unicorn.socket') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service("unicorn@1.service") do
    it { should be_enabled }
    it { should be_running }
  end
end
