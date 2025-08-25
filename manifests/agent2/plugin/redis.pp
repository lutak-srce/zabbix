# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring redis.
#
# @example
#   include zabbix::agent2::plugin::redis
#
class zabbix::agent2::plugin::redis (
  $file_ensure = $zabbix::agent::file_ensure,
) {
  file { "${zabbix::agent2::plugins_d}/redis.conf":
    ensure  => $file_ensure,
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/redis.conf.epp'),
    require => File[$zabbix::agent2::plugins_d],
    notify  => Service[$zabbix::agent2::service],
  }
}

