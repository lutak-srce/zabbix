# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring smart.
#
# @example
#   include zabbix::agent2::plugin::smart
#
class zabbix::agent2::plugin::smart {
  file { "${zabbix::agent2::plugins_d}/smart.conf":
    ensure  => file,
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/smart.conf.epp'),
    require => File[$zabbix::agent2::plugins_d],
    notify  => Service[$zabbix::agent2::service],
  }
}

