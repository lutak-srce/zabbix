# @summary 
#   Manages Zabbix agent configuration for network interface overruns monitoring.
#
# @example
#   include zabbix::agent::net_overruns
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::net_overruns inherits zabbix::agent {
  file { "${zabbix::agent::conf_dir}/net_overruns.conf":
    ensure  => file,
    source  => 'puppet:///modules/zabbix/agent/net_overruns.conf',
  }
}
