#
# = Class: zabbix::agent::iptables
#
# This module installs zabbix iptables plugin
#
class zabbix::agent::iptables (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  case $facts['os']['family'] {
    default: {
      $plugin_package = 'zabbix-agent_iptables'
    }
    /(RedHat|redhat|amazon)/: {
      $plugin_package = 'zabbix-agent_iptables'
    }
    /(Debian|debian|Ubuntu|ubuntu)/: {
      $plugin_package = 'libiptables-zabbix-agent'
    }
  }

  package { 'zabbix-agent_iptables':
    ensure  => present,
    name    => $plugin_package,
    require => Package['zabbix-agent'],
  }

}
