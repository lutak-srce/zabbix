# @summary 
#   Manages Zabbix agent configuration for beegfs monitoring.
#
# @example
#   include zabbix::agent::beegfs
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::beegfs inherits zabbix::agent {
  file { "${zabbix::agent::conf_dir}/beegfs.conf":
    ensure  => file,
    source  => 'puppet:///modules/zabbix/agent/beegfs/beegfs.conf',
    require => File["${zabbix::agent::dir_zabbix_agent_libdir}/zabbix-beegfs.pl"],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/zabbix-beegfs.pl":
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/beegfs/zabbix-beegfs.pl',
    require =>  Package['perl-JSON'],
  }

  package { 'perl-JSON':
    ensure => present,
  }
}
