# @summary 
#   Manages Zabbix agent configuration for monitoring NFS server.
#
# @example
#   include zabbix::agent::nfsserver
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::nfsserver inherits zabbix::agent {
  file { "${zabbix::agent::dir_zabbix_agentd_confd}/nfs_server.conf":
    ensure => file,
    owner  => $zabbix::agent::file_owner,
    group  => $zabbix::agent::file_group,
    mode   => $zabbix::agent::file_mode,
    source => 'puppet:///modules/zabbix/agent/nfs_server.conf',
    notify => Service[$zabbix::agent::service],
  }
}
