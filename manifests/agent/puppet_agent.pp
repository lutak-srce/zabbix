#
# Class: zabbix::agent::puppet_agent
#
# This module installs Puppet agent sensor
#
class zabbix::agent::puppet_agent (

  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,

) inherits zabbix::agent {

  sudoers::allowed_command { 'zabbix_puppet_agent' :
    command          => "${dir_zabbix_agent_libdir}/puppet_agent",
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix sensor for monitoring Puppet agent.',
  }

  file { "${conf_dir}/puppet_agent.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/puppet_agent.conf.erb'),
    notify  => Service[$agent_service],
    require => Package[$agent_package],
  }

  file { "${dir_zabbix_agent_libdir}/puppet_agent" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('zabbix/agent/puppet_agent.erb'),
    notify  => Service[$agent_service],
    require => ::Sudoers::Allowed_command['zabbix_puppet_agent'],
  }

}
