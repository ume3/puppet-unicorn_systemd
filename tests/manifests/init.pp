# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# https://docs.puppetlabs.com/guides/tests_smoke.html
#

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
    path        => '/usr/local/bin:/usr/bin:/bin',
    refreshonly => true,
  }
}

package { 'unicorn':
  ensure          => installed,
  provider        => gem,
  install_options => ['--no-document'],
  before          => Class['unicorn_systemd'];
}

file { '/srv/sample.ru':
  ensure  => present,
  content => file('unicorn_systemd/sample.ru'),
  mode    => '0755',
  before  => Class['unicorn_systemd'],
}

include 'unicorn_systemd'
