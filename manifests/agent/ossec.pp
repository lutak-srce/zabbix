#
# = Class: zabbix::agent::ossec
#
# This module installs zabbix ossec/wazuh sensor
#
class zabbix::agent::ossec (
  $server_package          = 'wazuh-manager',
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  ::sudoers::allowed_command { 'zabbix_sudo_ossec':
    command          => '/var/ossec/bin/agent_control -l',
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix sensor for monitoring OSSEC/Wazuh agents.',
  }

  file { "${conf_dir}/ossec.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/ossec.conf.erb'),
    notify  => Service[$agent_service],
    require => Package[$server_package],
  }

}
