# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring mongodb.
#
# @example
#   include zabbix::agent2::plugin::mongodb
#
# @note 
#   This class inherits all parameters from zabbix::agent2 class.
#
class zabbix::agent2::plugin::mongodb inherits zabbix::agent2 {
  file { "${zabbix::agent2::plugins_d}/mongodb.conf":
    ensure  => file,
    owner   => $zabbix::agent2::owner,
    group   => $zabbix::agent2::group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/mongodb.conf.epp'),
    require => File[$zabbix::agent2::plugins_d],
    notify  => Service[$zabbix::agent2::service],
  }
}

