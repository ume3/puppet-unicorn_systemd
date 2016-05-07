# puppet-unicorn\_systemd

[![Build Status](https://img.shields.io/travis/hfm/puppet-unicorn_systemd/master.svg?style=flat-square)](https://travis-ci.org/hfm/puppet-unicorn_systemd)
[![Puppet Forge](https://img.shields.io/puppetforge/v/hfm/unicorn_systemd.svg?style=flat-square)](https://forge.puppetlabs.com/hfm/unicorn_systemd)

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with unicorn_systemd](#setup)
    * [Beginning with unicorn_systemd](#beginning-with-unicorn_systemd)
1. [Usage - Configuration options and additional functionality](#usage)
  - [Configuring unicorn_systemd](#configuring-unicorn_systemd)
  - [Configuring modules from Hiera](#configuring-modules-from-hiera)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
  - [Classes](#classes)
    - [Public Classes](#public-classes)
    - [Private Classes](#private-classes)
  - [Parameters](#parameters)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module handles configuring and running [unicorn](http://unicorn.bogomips.org/) service for systemd.

## Setup

### Beginning with unicorn_systemd

To configure the unicorn with default parameters, declare the `unicorn_systemd` class.

```puppet
include ::unicorn_systemd
```

## Usage

### Configuring unicorn_systemd

```puppet
class { 'unicorn_systemd':
  user              => 'app',
  working_directory => '/srv',
  listen_streams    => ['0.0.0.0:9000', '0.0.0.0:9001'],
  exec_start        => '/usr/local/bin/unicorn -E $RAILS_ENV /srv/sample.ru',
  environment       => 'RAILS_ENV=production'
}
```

### Configuring modules from Hiera

```yaml
---
unicorn_systemd::user: app
unicorn_systemd::working_directory: /srv
unicorn_systemd::listen_streams:
  - 0.0.0.0:9000
  - 0.0.0.0:9001
unicorn_systemd::exec_start: /usr/local/bin/unicorn -E $RAILS_ENV /srv/sample.ru
unicorn_systemd::environment:
  RAILS_ENV: production
```

## Reference

### Classes

#### Public Classes

- [`unicorn_systemd`](#unicorn_systemd): Configures unicorn service files and sysconfig.

#### Private Classes

- `unicorn_systemd::install`: Installs unicorn initsystem file.
- `unicorn_systemd::service`: Manages service.

### Parameters

#### unicorn_systemd

- `ensure`: Whether the unit files should exist. Valid options: present, absent, file. Default to present.
- `user`: The user to execute the processes as. Valid options: a string containing a valid username.  Default to 'nobody'.
- `group`: The group to execute the processes as. Valid options: a string containing a valid groupname.  Default to undef.
- `working_directory`: The working directory for executed processes. Valid options: an absolute path.  Default to undef.
- `listen_streams`: The addresses to listen on for a stream. Valid options: an array of valid addresses.  Default to ['127.0.0.1:8080', '/var/run/unicorn.sock'].
- `exec_start`: The commands with their arguments that are executed for this service. Valid options: a string containing valid commands.  Default to undef.
- `environment`: The environment variables for executed processes. Valid options: a hash of key-value pairs.  Default to {}.
- `service_ensure`: Whether the service should be enabled. Valid options: 'running', 'true', 'stopped', or 'false'.  Defaults to running.
- `service_enable`: Whether the service should be enabled. Valid options: a boolean.  Defaults to true.

## Limitations

This module has been tested on:

- RedHat Enterprise Linux 7
- CentOS 7
- Scientific Linux 7
- Debian 8
- Ubuntu 15.10
- Ubuntu 16.04

## Development

### Running tests

The STNS puppet module contains tests for both [rspec-puppet](http://rspec-puppet.com/) (unit tests) and [beaker-rspec](https://github.com/puppetlabs/beaker-rspec) (acceptance tests) to verify functionality. For detailed information on using these tools, please see their respective documentation.

#### Testing quickstart

- Unit tests:

```console
$ bundle install
$ bundle exec rake
```

- Acceptance tests:

```console
# Set your DOCKER_HOST variable
$ eval "$(docker-machine env default)"

# Run beaker acceptance tests
$ BEAKER_set=centos7 bundle exec rake beaker
```
