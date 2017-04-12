# == Class: unicorn_systemd
#
# This class install and configure systemd unit files for unicorn
#
# === Parameters
#
# * `ensure`
# Whether the unit files should exist. Valid options: present, absent, file.
# Default to present.
#
# * `user`
# The user to execute the processes as. Valid options: a string containing a valid username.
# Default to 'nobody'.
#
# * `group
# The group to execute the processes as. Valid options: a string containing a valid groupname.
# Default to undef.
#
# * `working_directory`
# The working directory for executed processes. Valid options: an absolute path.
# Default to undef.
#
# * `listen_streams`
# The addresses to listen on for a stream. Valid options: an array of valid addresses.
# Default to ['127.0.0.1:8080', '/var/run/unicorn.sock'].
#
# * `exec_start`
# The commands with their arguments that are executed for this service. Valid options: a string containing valid commands.
# Default to undef.
#
# * `environment`
# The environment variables for executed processes. Valid options: a hash of key-value pairs.
# Default to {}.
#
# * `service_ensure`
# Whether the service should be enabled. Valid options: 'running', 'true', 'stopped', or 'false'.
# Defaults to running.
#
# * `service_enable`
# Whether the service should be enabled. Valid options: a boolean.
# Defaults to true.
#
#
# === Examples
#
# @example
#    class { 'unicorn_systemd':
#      user              => 'app',
#      group             => 'app',
#      working_directory => '/srv',
#      listen_streams    => ['0.0.0.0:9000', '0.0.0.0:9001'],
#      exec_start        => '/usr/local/bin/unicorn /srv/sample.ru',
#    }
#
class unicorn_systemd (
  String $user,
  String $group,
  String $working_directory,
  String $pidfile,
  Hash[String, String] $environment,
  String $exec_start,
  String $ensure = present,
  String $service_ensure = running,
  Boolean $service_enable = true,
) {

  include ::systemd

  file { '/etc/systemd/system/unicorn.service':
    ensure  => $ensure,
    content => template('unicorn_systemd/unicorn.service.erb'),
    owner   => 'root',
    group   => 'root',
    notify  => Exec['systemctl-daemon-reload'],
  }

  service { 'unicorn.service':
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => File['/etc/systemd/system/unicorn.service'],
  }

}
