class unicorn_systemd::install (
  $ensure            = present,
  $user              = 'nobody',
  $group             = undef,
  $working_directory = undef,
  $listen_streams    = ['127.0.0.1:8080', '/var/run/unicorn.sock'],
  $exec_start        = undef,
){

  validate_string($user)
  validate_string($group)
  validate_absolute_path($working_directory)
  if is_string($listen_streams) {
    any2array($listen_streams)
  } else {
    validate_array($listen_streams)
  }
  validate_string($exec_start)

  file {
    '/etc/systemd/system/unicorn.socket':
      ensure  => $ensure,
      content => template('unicorn_systemd/unicorn.socket.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644';

    '/etc/systemd/system/unicorn@.service':
      ensure  => $ensure,
      content => template('unicorn_systemd/unicorn@.service.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644';
  }

}
