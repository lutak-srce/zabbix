#
# = Class: zabbix::agent::apache
#
# This module installs zabbix apache plugin
#
class zabbix::agent::apache (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $status_address          = 'localhost'
) inherits zabbix::agent {

  package { 'curl':
    ensure => present,
  }

  file { "${conf_dir}/apache2.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/apache2.conf.erb'),
    require => [
      File["${dir_zabbix_agent_libdir}/apache2.pl"],
      Package[$agent_package],
    ],
    notify  => Service[$agent_service],
  }

  file { "${dir_zabbix_agent_libdir}/apache2.pl" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('zabbix/agent/apache2.pl.erb'),
    require => [
      Package['curl'],
    ],
    notify  => Service[$agent_service],
  }

}
