# @summary 
#   Manages Zabbix agent configuration for tcp monitoring.
#
# @example
#   include zabbix::agent::tcp
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::tcp (
  $module = "puppet:///modules/zabbix/agent/modules/${facts[os][family]}/${facts[os][release][major]}/tcp_count.so"
) inherits zabbix::agent {

  file { "${zabbix::agent::conf_dir}/tcp.conf":
    ensure  => file,
    source  => 'puppet:///modules/zabbix/agent/tcp.conf',
    require => File["${zabbix::agent::dir_zabbix_agent_modules}/tcp_count.so"],
  }

  file { "${zabbix::agent::dir_zabbix_agent_modules}/tcp_count.so":
    ensure => file,
    source => $module,
  }
}
