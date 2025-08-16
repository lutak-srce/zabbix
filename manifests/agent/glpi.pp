#
# = Class: zabbix::agent::glpi
#
# This module installs Zabbix GLPI sensor
#
class zabbix::agent::glpi (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $script_source           = 'puppet:///modules/zabbix/agent/glpi/glpi2zabbix.py',
  $glpi_url                = 'https://localhost/glpi',
  $glpi_apptoken           = 'api',
  $glpi_usertoken          = 'api',
  $zabbix_url              = 'https://localhost/zabbix',
  $zabbix_username         = 'api',
  $zabbix_password         = 'api',
) inherits zabbix::agent {

  file { '/etc/cron.hourly/glpi2zabbix' :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0750',
    content => template('zabbix/agent/glpi2zabbix.erb'),
    require => [
      Package[$agent_package],
      File["${dir_zabbix_agent_libdir}/glpi2zabbix.py"],
      Package['pyzabbix'],
    ],
  }

  file { "${dir_zabbix_agent_libdir}/glpi2zabbix.py" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => $script_source,
  }

  package { 'pyzabbix':
    ensure   => present,
    provider => 'pip',
  }

}
