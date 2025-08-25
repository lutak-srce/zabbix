# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring modbus.
#
# @example
#   include zabbix::agent2::plugin::modbus
#
class zabbix::agent2::plugin::modbus {
  file { "${zabbix::agent2::plugins_d}/modbus.conf":
    ensure  => file,
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/modbus.conf.epp'),
    require => File[$zabbix::agent2::plugins_d],
    notify  => Service[$zabbix::agent2::service],
  }
}

