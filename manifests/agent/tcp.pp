#
# = Class: zabbix::agent::tcp
#
# Add module for TCP connections
#
class zabbix::agent::tcp (
  $conf_dir                 = $::zabbix::agent::conf_dir,
  $agent_service            = $::zabbix::agent::service_state,
  $agent_package            = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_modules = $::zabbix::agent::dir_zabbix_agent_modules,
  $module                   = "puppet:///modules/zabbix/agent/modules/${facts[os][family]}/${facts[os][release][major]}/tcp_count.so"
) inherits zabbix::agent {

  file { "${conf_dir}/tcp.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/zabbix/agent/tcp.conf',
    notify  => Service[$agent_service],
    require => [ Package[$agent_package], File["${dir_zabbix_agent_modules}/tcp_count.so"] ],
  }

  file { "${dir_zabbix_agent_modules}/tcp_count.so" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
    source => $module,
    notify => Service[$agent_service],
  }
}
