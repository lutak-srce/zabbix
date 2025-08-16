#
# = Class: zabbix::agent::ib
#
# This module installs Zabbix Infiniband sensor
#
class zabbix::agent::ib (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $extended                = 1,
  $period                  = '',
) inherits zabbix::agent {

  ::sudoers::allowed_command { 'zabbix_sudo_ib':
    command          => '/usr/sbin/perfquery',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix Infiniband sensor',
  }

  file { "${conf_dir}/ib.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/ib.conf.erb'),
    require => [
      Package[$agent_package],
      Package['infiniband-diags'],
      File["${dir_zabbix_agent_libdir}/zabbix-ib.pl"],
    ],
    notify  => Service[$agent_service],
  }

  file { "${dir_zabbix_agent_libdir}/zabbix-ib.pl" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/zabbix-ib.pl',
    require => ::Sudoers::Allowed_command['zabbix_sudo_ib'],
  }

}
