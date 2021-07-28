# -*- mode: ruby -*-
# vi: set ft=ruby sw=2 st=2 et :
# frozen_string_literal: true

require 'yaml'
#TODO voir si ça sert
require 'erb'

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'
ENV['VAGRANT_NO_PARALLEL'] = 'yes'

# Define settings for all machines
# Virer les ports pour MariaDB et voir si ça marche
SERVERS_DATA = YAML.safe_load(
  <<-YAML
  ---
  control:
    ipaddr: 192.168.50.10
    memory: 512
    ports: []
  s0.infra:
    ipaddr: 192.168.50.20
    memory: 512
    ports:
      - { guest: 80, host: 80 }
  s1.infra:
    ipaddr: 192.168.50.30
    memory: 512
    ports: []
  s2.infra:
    ipaddr: 192.168.50.40
    memory: 512
    ports: []
  s3.infra:
    ipaddr: 192.168.50.50
    memory: 512
    ports:
      - { guest: 3306, host: 3306 }
  s4.infra:
    ipaddr: 192.168.50.60
    memory: 512
    ports:
      - { guest: 80, host: 8080 }
  YAML
  .gsub(/^  /, '')
)

# Load lan suffix from .env
LAN_SUFFIX = File.readlines('.env')
                 .select { |line| line =~ /LAN_SUFFIX=/ }
                 .first
                 .gsub(/LAN_SUFFIX=/, '')
                 .gsub(/^\./, '')
                 .strip

# Build host file in-memory
HOSTS_FILE = ERB.new(
  <<-HOSTS_TEMPLATE
  ## BEGIN PROVISION
  <% hosts = SERVERS_DATA.map{ |key,value| OpenStruct.new(name: key, ipaddr: value['ipaddr']) } -%>
  <% lansuffix = (LAN_SUFFIX.nil? || LAN_SUFFIX.empty?) ? '' : ('.' + LAN_SUFFIX) -%>
  <% for item in hosts -%>
  <%= item.ipaddr %>\t<%= item.name %> <%= item.name %><%= lansuffix %>
  <% end -%>
  ## END PROVISION
  HOSTS_TEMPLATE
  .gsub(/^\s+/, ''),
  nil,
  '-'
).result(binding)

Vagrant.configure('2') do |config|
  config.vm.box = 'debian/buster64'
  config.vm.box_check_update = false

  SERVERS_DATA.keys.each.with_index do |name, idx|
    config.vm.define name.to_s do |machine|
      # Limit memory & CPU consumption
      machine.vm.provider 'virtualbox' do |vb|
        # vb.customize ['modifyvm', :id, '--cpuexecutioncap', '50']
        vb.memory = SERVERS_DATA[name.to_s]['memory'].to_i
        vb.cpus = 2
        vb.gui = false
      end

      machine.vm.hostname = name.to_s
      machine.vm.network 'private_network',
                         ip: SERVERS_DATA[name.to_s]['ipaddr']

      SERVERS_DATA[name.to_s]['ports'].each do |port|
        machine.vm.network 'forwarded_port', guest: port['guest'], host: port['host']
      end

      # Inject all hosts
      machine.vm.provision(
        'shell',
        inline: (
          <<-SCRIPT
          sed -i -e '/^## BEGIN PROVISION/,/^## END PROVISION/d' /etc/hosts
          echo "#{HOSTS_FILE}" >> /etc/hosts
          SCRIPT
          .gsub('/^\s+/', '')
        )
      )
      machine.vm.provision 'shell', path: 'provision.sh'
    end
  end
end