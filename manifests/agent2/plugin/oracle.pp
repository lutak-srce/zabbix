# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring oracle.
#
# @example
#   include zabbix::agent2::plugin::oracle
#
class zabbix::agent2::plugin::oracle (
  $file_ensure = $zabbix::agent2::file_ensure,
) {
  file { "${zabbix::agent2::plugins_d}/oracle.conf":
    ensure  => $file_ensure,
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/oracle.conf.epp'),
    notify  => Service[$zabbix::agent2::service_name],
  }
}

