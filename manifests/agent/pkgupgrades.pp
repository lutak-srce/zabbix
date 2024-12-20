#
# = Class: zabbix::agent::pkgupgrades
#
# This module installs zabbix plugin for counting pending upgrades
#
class zabbix::agent::pkgupgrades (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  case $facts['os']['family'] {
    default: {}
    /(RedHat|redhat|amazon)/: {
      file { "${dir_zabbix_agentd_confd}/pkgupgrades.conf" :
        ensure  => file,
        owner   => root,
        group   => root,
        content => template('zabbix/agent/pkgupgrades-rhel.conf.erb'),
        notify  => Service['zabbix-agent'],
      }
      
      ::sudoers::allowed_command { 'zabbix_yum':
        command          => "/usr/bin/yum -y -q check-update",
        user             => 'zabbix',
        require_password => false,
        comment          => 'Zabbix sensor for monitoring packages pending upgrade.',
      }
    }
    /(Debian|debian|Ubuntu|ubuntu)/: {
      file { "${dir_zabbix_agentd_confd}/pkgupgrades.conf" :
        ensure  => file,
        owner   => root,
        group   => root,
        content => template('zabbix/agent/pkgupgrades-debian.conf.erb'),
        notify  => Service['zabbix-agent'],
      }
    }
  }
}
