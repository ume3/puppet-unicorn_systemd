# -*- mode: ruby -*-
# vi: set ft=ruby :

module VagrantPlugins
  module LibrarianPuppet
    class Plugin < Vagrant.plugin(2)
      name 'vagrant-librarian-puppet'
      description 'Installation of Puppet modules via librarian-puppet'
      action_hook 'librarian_puppet' do |hook|
        hook.before Vagrant::Action::Builtin::Provision, Action
      end
    end

    class Action
      def initialize(app, _)
        @app = app
      end

      def call(env)
        env[:ui].info 'Running pre-provisioner: librarian-puppet...'

        Vagrant::Util::Env.with_clean_env do
          ENV.reject! {|_,v| v.match /vagrant/i}
          cmd = 'bundle exec librarian-puppet install --path tests/modules --verbose'
          env[:ui].detail `#{cmd}`
        end

        @app.call(env)
      end
    end
  end
end

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
