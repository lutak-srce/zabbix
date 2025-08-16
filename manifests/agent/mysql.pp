#
# = Class: zabbix::agent::mysql
#
# This module installs zabbix mysql sensor
#
class zabbix::agent::mysql (
  $options                 = '',
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $conf_dir                = $::zabbix::agent::conf_dir,
) inherits zabbix::agent {

  package { 'zabbix-agent_mysql':
    ensure  => present,
    require => Package[$agent_package],
  }

  file { "${conf_dir}/mysql.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/mysql.conf.erb'),
    require => Package['zabbix-agent_mysql'],
    notify  => Service[$agent_service],
  }

}
