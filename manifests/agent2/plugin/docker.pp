# @summary 
#   Manages Zabbix agent2 plugin configuration for monitoring docker.
#
# @example
#   include zabbix::agent2::plugin::docker
#
class zabbix::agent2::plugin::docker (
  $file_ensure = $zabbix::agent2::file_ensure,
) {
  file { "${zabbix::agent2::plugins_d}/docker.conf":
    ensure  => $file_ensure,
    owner   => $zabbix::agent2::file_owner,
    group   => $zabbix::agent2::file_group,
    mode    => $zabbix::agent2::file_mode,
    content => epp('zabbix/agent2/plugin/docker.conf.epp'),
    notify  => Service[$zabbix::agent2::service_name],
  }
}

