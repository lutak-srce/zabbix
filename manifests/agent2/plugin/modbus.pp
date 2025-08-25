# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring modbus.
#
# @example
#   include zabbix::agent2::plugin::modbus
#
class zabbix::agent2::plugin::modbus (
  $file_ensure = $zabbix::agent2::file_ensure,
) {
  file { "${zabbix::agent2::plugins_d}/modbus.conf":
    ensure  => $file_ensure,
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/modbus.conf.epp'),
    notify  => Service[$zabbix::agent2::service_name],
  }
}

