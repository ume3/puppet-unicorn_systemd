class unicorn_systemd::install (
  $user              = $unicorn_systemd::user,
  $group             = $unicorn_systemd::group,
  $working_directory = $unicorn_systemd::working_directory,
  $listen_streams    = $unicorn_systemd::listen_streams,
  $exec_start        = $unicorn_systemd::exec_start,
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
      content => template('unicorn_systemd/unicorn.socket.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644';

    '/etc/systemd/system/unicorn@.service':
      content => template('unicorn_systemd/unicorn@.service.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644';
  }

}
