# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring memcached.
#
# @example
#   include zabbix::agent2::plugin::memcached
#
class zabbix::agent2::plugin::memcached (
  $file_ensure = $zabbix::agent::file_ensure,
) {
  file { "${zabbix::agent2::plugins_d}/memcached.conf":
    ensure  => $file_ensure,
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/memcached.conf.epp'),
    notify  => Service[$zabbix::agent2::service_name],
  }
}

