# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring postgresql.
#
# @example
#   include zabbix::agent2::plugin::postgresql
#
class zabbix::agent2::plugin::postgresql (
  $file_ensure = $zabbix::agent2::file_ensure,
) {
  file { "${zabbix::agent2::plugins_d}/postgresql.conf":
    ensure  => $file_ensure,
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/postgresql.conf.epp'),
    notify  => Service[$zabbix::agent2::service_name],
  }
}

