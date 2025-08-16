#
# = Class: zabbix::agent::sge
#
# This module installs Zabbix SGE sensor
#
class zabbix::agent::sge (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${conf_dir}/sge.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/sge.conf.erb'),
    require => [
      Package[$agent_package],
      File["${dir_zabbix_agent_libdir}/sge.pl"],
      File["${dir_zabbix_agent_libdir}/sge-lld.pl"],
      Package['perl-JSON'],
    ],
    notify  => Service[$agent_service],
  }

  package { 'perl-JSON':
    ensure =>   present
  }

  file { "${dir_zabbix_agent_libdir}/sge.pl" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/sge/sge.pl',
  }

  file { "${dir_zabbix_agent_libdir}/sge-lld.pl" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source =>  'puppet:///modules/zabbix/agent/sge/sge-lld.pl',
  }

}
