# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring mqtt.
#
# @example
#   include zabbix::agent2::plugin::mqtt
#
class zabbix::agent2::plugin::mqtt {
  file { "${zabbix::agent2::plugins_d}/mqtt.conf":
    ensure  => file,
    owner   => $zabbix::agent2::owner,
    group   => $zabbix::agent2::group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/mqtt.conf.epp'),
    require => File[$zabbix::agent2::plugins_d],
    notify  => Service[$zabbix::agent2::service],
  }
}

