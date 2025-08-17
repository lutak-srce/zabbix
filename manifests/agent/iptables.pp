# @summary 
#   Manages Zabbix agent configuration for iptables monitoring.
#
# @example
#   include zabbix::agent::iptables
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::iptables inherits zabbix::agent {
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
    require => Package[$zabbix::agent::agent_package],
  }
}
