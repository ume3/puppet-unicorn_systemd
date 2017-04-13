# == Class: unicorn_systemd
#
# This class install and configure systemd unit files for unicorn
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

  service { 'unicorn':
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => File['/etc/systemd/system/unicorn.service'],
  }

}
