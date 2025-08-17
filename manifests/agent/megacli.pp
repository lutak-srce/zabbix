# @summary 
#   Manages Zabbix agent configuration for megacli monitoring.
#
# @example
#   include zabbix::agent::megacli
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::megacli inherits zabbix::agent {
  package { 'zabbix-agent_megacli':
    ensure  => present,
    require => Package[$zabbix::agent::agent_package],
  }
}
