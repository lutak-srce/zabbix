# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring ceph.
#
# @example
#   include zabbix::agent2::plugin::ceph
#
# @note 
#   This class inherits all parameters from zabbix::agent2 class.
#
class zabbix::agent2::plugin::ceph inherits zabbix::agent2 {
  file { "${zabbix::agent2::plugins_d}/ceph.conf":
    ensure  => file,
    owner   => $zabbix::agent2::owner,
    group   => $zabbix::agent2::group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/ceph.conf.epp'),
    require => File[$zabbix::agent2::plugins_d],
    notify  => Service[$zabbix::agent2::service],
  }
}
