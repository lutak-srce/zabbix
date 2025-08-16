#
# = Class: zabbix::agent::beegfs
#
# This module installs Zabbix BeeGFS sensor
#
class zabbix::agent::beegfs (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${conf_dir}/beegfs.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  =>  'puppet:///modules/zabbix/agent/beegfs/beegfs.conf',
    require => [
      Package[$agent_package],
      File["${dir_zabbix_agent_libdir}/zabbix-beegfs.pl"],
    ],
    notify  => Service[$agent_service],
  }

  file { "${dir_zabbix_agent_libdir}/zabbix-beegfs.pl" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/beegfs/zabbix-beegfs.pl',
    require =>  [
      Package[$agent_package],
      Package['perl-JSON'],
    ],
  }

  package { 'perl-JSON':
    ensure => present,
  }
}
