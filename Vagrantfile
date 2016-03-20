# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'

platforms = {
  centos7: 'puppetlabs/centos-7.2-64-puppet',
  jessie: 'puppetlabs/debian-8.2-64-puppet',
}

Vagrant.configure(2) do |config|
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
  end

  metadata = JSON.parse(File.read('metadata.json'))
  module_name = metadata['name'].split('-').last

  config.vm.provision :shell,
    inline: "ln -sfn /vagrant/ /vagrant/tests/modules/#{module_name}"

  config.vm.provision :puppet do |puppet|
    puppet.environment_path = '.'
    puppet.environment      = 'tests'
    puppet.module_path      = 'tests/modules'
    puppet.options          = [
      '--detailed-exitcodes',
      '--show_diff',
      '--verbose',
      # '--debug',
    ]
    puppet.hiera_config_path = 'tests/hiera.yaml'
  end

  platforms.each do |dist, box|
    config.vm.define dist do |platform|
      platform.vm.box       = box
      platform.vm.host_name = dist
    end
  end
end
