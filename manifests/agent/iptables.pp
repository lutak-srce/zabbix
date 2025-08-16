#
# = Class: zabbix::agent::iptables
#
# This module installs zabbix iptables plugin
#
class zabbix::agent::iptables (
  $conf_dir = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
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
    require => Package[$agent_package],
  }

}
