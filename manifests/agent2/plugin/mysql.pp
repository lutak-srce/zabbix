# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring mysql.
#
# @example
#   include zabbix::agent2::plugin::mysql
#
class zabbix::agent2::plugin::mysql (
  $file_ensure = $zabbix::agent::file_ensure,
) {
  file { "${zabbix::agent2::plugins_d}/mysql.conf":
    ensure  => $file_ensure,
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/mysql.conf.epp'),
    notify  => Service[$zabbix::agent2::service_name],
  }
}
