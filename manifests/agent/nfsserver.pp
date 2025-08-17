# @summary 
#   Manages Zabbix agent configuration for NFS server monitoring.
#
# @example
#   include zabbix::agent::nfsserver
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::nfsserver inherits zabbix::agent {
  file { "${zabbix::agent::conf_dir}/nfs_server.conf" :
    ensure => file,
    source => 'puppet:///modules/zabbix/agent/nfs_server.conf',
  }
}
