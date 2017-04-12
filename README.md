# puppet-unicorn\_systemd

[![Build Status](https://img.shields.io/travis/hfm/puppet-unicorn_systemd/master.svg?style=flat-square)](https://travis-ci.org/hfm/puppet-unicorn_systemd)
[![Puppet Forge](https://img.shields.io/puppetforge/v/hfm/unicorn_systemd.svg?style=flat-square)](https://forge.puppetlabs.com/hfm/unicorn_systemd)

#### Table of Contents

1. [Description](#description)
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

## Usage

### Configuring unicorn_systemd

```puppet
class { 'unicorn_systemd':
  user              => 'app',
  group             => 'app',
  working_directory => '/srv',
  pidfile           => '/var/run/unicorn.pid',
  exec_start        => '/usr/local/bin/unicorn -E $RAILS_ENV /srv/sample.ru',
  environment       => {
    'RAILS_ENV=production',
    'UNICORN_RB=config/unicorn.rb',
  }
}
```

### Configuring modules from Hiera

```yaml
---
unicorn_systemd::user: app
unicorn_systemd::group: app
unicorn_systemd::working_directory: /srv
unicorn_systemd::pidfile: /var/run/unicorn.pid
unicorn_systemd::exec_start: /usr/local/bin/unicorn -E $RAILS_ENV -c $UNICORN_RB /srv/sample.ru
unicorn_systemd::environment:
  RAILS_ENV: production
  UNICORN_RB: config/unicorn.rb
```

## Reference

### Classes

#### Public Classes

- [`unicorn_systemd`](#unicorn_systemd): Configures unicorn service files and sysconfig.

### Parameters

#### unicorn_systemd

- `user`: The user to execute the processes as. String type.
- `group`: The group to execute the processes as. String type.
- `working_directory`: The working directory for executed processes. String type.
- `pidfile`: The pidfile for unicorn master process. String type.
- `exec_start`: The commands with their arguments that are executed for this service. String type.
- `environment`: The environment variables for executed processes. Hashes type.
- `ensure`: Whether the unit files should exist. Valid options: present, absent, file. Default to present.
- `service_ensure`: Whether the service should be enabled. String type. Defaults to running.
- `service_enable`: Whether the service should be enabled. Boolean type. Defaults to true.

## Limitations

This module has been tested on:

- RedHat Enterprise Linux 7
- CentOS 7
- Scientific Linux 7
- Debian 8
- Ubuntu 16.04

## Development

### Running tests

The STNS puppet module contains tests for [beaker-rspec](https://github.com/puppetlabs/beaker-rspec) (acceptance tests) to verify functionality. For detailed information on using these tools, please see their respective documentation.

#### Testing quickstart

- Acceptance tests:

```console
# Set your DOCKER_HOST variable
$ eval "$(docker-machine env default)"

# Run beaker acceptance tests
$ BEAKER_set=centos7 bundle exec rake beaker
```
