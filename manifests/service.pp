class unicorn_systemd::service (
  $service_ensure = running,
  $service_enable = true,
) {

  validate_re($service_ensure, '^(true|running|false|stopped)$', 'This parameter should be true(running) or false(stopped).')
  validate_bool($service_enable)

  service {
    'unicorn.socket':
      ensure => $service_ensure,
      enable => $service_enable,
      before => Service['unicorn@1.service'];

    [
      'unicorn@1.service',
      'unicorn@2.service',
    ]:
      ensure => $service_ensure,
      enable => $service_enable;
  }

}
