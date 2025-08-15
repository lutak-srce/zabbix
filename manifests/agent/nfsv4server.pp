#
# = Class: zabbix::agent::nfsv4server
#
# NFSv4 Server Stats
#
class zabbix::agent::nfsv4server (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/nfsv4_server.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/zabbix/agent/nfsv4_server.conf',
    notify  => Service['zabbix-agent'],
    require => Package['zabbix-agent'],
  }
}
