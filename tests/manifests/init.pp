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
package {
  ['rubygems', 'ruby-devel', 'make']:
    ensure => installed,
    before => Package['unicorn'];

  'unicorn':
    ensure   => installed,
    provider => gem,
    before   => Class['unicorn_systemd'];
}

file { '/srv/sample.ru':
  ensure  => present,
  content => file('unicorn_systemd/sample.ru'),
  mode    => '0755',
  before  => Class['unicorn_systemd'],
}

include 'unicorn_systemd'
