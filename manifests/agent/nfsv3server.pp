#
# = Class: zabbix::agent::nfsv3server
#
# NFSv3 Server Stats
#
class zabbix::agent::nfsv3server (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/nfsv3_server.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/zabbix/agent/nfsv3_server.conf',
    notify  => Service['zabbix-agent'],
    require => Package['zabbix-agent'],
  }
}
