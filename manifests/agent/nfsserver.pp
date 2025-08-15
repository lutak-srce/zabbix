#
# = Class: zabbix::agent::nfsserver
#
# NFS Server Stats
#
class zabbix::agent::nfsserver (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/nfs_server.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/zabbix/agent/nfs_server.conf',
    notify  => Service['zabbix-agent'],
    require => Package['zabbix-agent'],
  }
}
