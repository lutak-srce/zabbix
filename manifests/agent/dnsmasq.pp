# @summary 
#   Manages Zabbix agent configuration for dnsmasq monitoring.
#
# @example
#   include zabbix::agent::dnsmasq
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::dnsmasq inherits zabbix::agent {
  file { "${zabbix::agent::conf_dir}/dnsmasq.conf":
    ensure  => file,
    content => template('zabbix/agent/dnsmasq.conf.erb'),
  }
}
