#
# = Class: zabbix::agent::dnsmasq
#
# This module installs zabbix dnsmasq sensor
#
class zabbix::agent::dnsmasq (
  $options                 = '',
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${conf_dir}/dnsmasq.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/dnsmasq.conf.erb'),
    notify  => Service[$agent_service],
    require => [ Package['dnsmasq'] ],
  }

}
