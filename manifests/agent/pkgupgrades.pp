#
# = Class: zabbix::agent::pkgupgrades
#
# This module installs zabbix plugin for counting pending upgrades
#
class zabbix::agent::pkgupgrades (
  $conf_dir      = $::zabbix::agent::conf_dir,
  $agent_service = $::zabbix::agent::service_state,
  $agent_package = $::zabbix::agent::agent_package,
) inherits zabbix::agent {

  case $facts['os']['family'] {
    default: {}
    /(RedHat|redhat|amazon)/: {
      file { "${conf_dir}/pkgupgrades.conf" :
        ensure  => file,
        owner   => root,
        group   => root,
        content => template('zabbix/agent/pkgupgrades-rhel.conf.erb'),
        notify  => Service[$agent_service],
      }

      ::sudoers::allowed_command { 'zabbix_yum':
        command          => '/usr/bin/yum -y -q check-update',
        user             => 'zabbix',
        require_password => false,
        comment          => 'Zabbix sensor for monitoring packages pending upgrade.',
      }
    }
    /(Debian|debian|Ubuntu|ubuntu)/: {
      file { "${conf_dir}/pkgupgrades.conf" :
        ensure  => file,
        owner   => root,
        group   => root,
        content => template('zabbix/agent/pkgupgrades-debian.conf.erb'),
        notify  => Service[$agent_service],
      }
    }
  }
}
