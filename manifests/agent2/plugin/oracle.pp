# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring oracle.
#
# @example
#   include zabbix::agent2::plugin::oracle
#
class zabbix::agent2::plugin::oracle {
  file { "${zabbix::agent2::plugins_d}/oracle.conf":
    ensure  => file,
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/oracle.conf.epp'),
    require => File[$zabbix::agent2::plugins_d],
    notify  => Service[$zabbix::agent2::service],
  }
}

