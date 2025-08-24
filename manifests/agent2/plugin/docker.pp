# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring docker.
#
# @example
#   include zabbix::agent2::plugin::docker
#
class zabbix::agent2::plugin::docker {
  file { "${zabbix::agent2::plugins_d}/docker.conf":
    ensure  => file,
    owner   => $zabbix::agent2::owner,
    group   => $zabbix::agent2::group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/docker.conf.epp'),
    require => File[$zabbix::agent2::plugins_d],
    notify  => Service[$zabbix::agent2::service],
  }
}

