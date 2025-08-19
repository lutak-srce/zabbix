# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring mysql.
#
# @example
#   include zabbix::agent2::plugin::mysql
#
# @note 
#   This class inherits all parameters from zabbix::agent2 class.
#
class zabbix::agent2::plugin::mysql inherits zabbix::agent2 {
  file { "${zabbix::agent2::plugins_d}/mysql.conf":
    ensure  => file,
    owner   => $zabbix::agent2::owner,
    group   => $zabbix::agent2::group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/mysql.conf.epp'),
    require => File[$zabbix::agent2::plugins_d],
    notify  => Service[$zabbix::agent2::service],
  }
}
