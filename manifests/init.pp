# == Class: unicorn_systemd
#
# This class install and configure systemd unit files for unicorn
#
# === Parameters
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
  $user              = 'nobody',
  $group             = undef,
  $working_directory = undef,
  $listen_streams    = ['127.0.0.1:8080', '/var/run/unicorn.sock'],
  $exec_start        = undef,

  $service_ensure    = running,
  $service_enable    = true,
) {

  class { 'unicorn_systemd::install':
    user              => $user,
    group             => $group,
    working_directory => $working_directory,
    listen_streams    => $listen_streams,
    exec_start        => $exec_start,
  }

  class { 'unicorn_systemd::service':
    service_ensure => $service_ensure,
    service_enable => $service_enable,
    subscribe      => Class['unicorn_systemd::install'],
    require        => Class['unicorn_systemd::install'],
  }

}
