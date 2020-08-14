#
# = Class: zabbix::agent::apache
#
# This module installs zabbix apache plugin
#
class zabbix::agent::apache (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  package { 'curl':
    ensure => present,
  }

  ::sudoers::allowed_command { 'zabbix_apache2':
    command          => "${dir_zabbix_agent_libdir}/apache2.pl",
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix sensor for apache2 server-status.',
  }

  file { "${dir_zabbix_agentd_confd}/apache2.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/apache2.conf.erb'),
    require => [
      File["${dir_zabbix_agent_libdir}/apache2.pl"],
      Package['zabbix-agent'],
    ],
    notify  => Service['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/apache2.pl" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/apache2.pl',
    require => [
      Package['curl'],
    ],
    notify  => Service['zabbix-agent'],
  }

}
