#
# = Class: zabbix::agent::mdraid
#
# This module installs zabbix mdraid sensor
#
class zabbix::agent::mdraid (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  ::sudoers::allowed_command { 'zabbix_sudo_mdadm':
    command          => '/sbin/mdadm --detail /dev/md[0-9]*',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix mdadm --detail listing',
  }

  file { "${conf_dir}/mdraid.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/mdraid.conf.erb'),
    require => [
      Package[$agent_package],
      File["${dir_zabbix_agent_libdir}/check_mdraid"],
    ],
    notify  => Service[$agent_service],
  }

  file { "${dir_zabbix_agent_libdir}/check_mdraid" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/check_mdraid',
    require => ::Sudoers::Allowed_command['zabbix_sudo_mdadm'],
  }

}
