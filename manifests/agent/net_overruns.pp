#
# = Class: zabbix::agent::net_overruns
#
# Adds items for network interface overruns items
#
class zabbix::agent::net_overruns (
  $conf_dir = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
) inherits zabbix::agent {

  file { "${conf_dir}/net_overruns.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/zabbix/agent/net_overruns.conf',
    notify  => Service[$agent_service],
    require => Package[$agent_package],
  }
}
