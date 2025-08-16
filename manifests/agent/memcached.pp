#
# = Class: zabbix::agent::mmemcached
#
# This module installs zabbix memcached sensor
#
class zabbix::agent::memcached (
  $options                 = '',
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${conf_dir}/memcached.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/memcached.conf.erb'),
    notify  => Service[$agent_service],
  }

  file { "${dir_zabbix_agent_libdir}/memcached.pl" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/memcached.pl',
    notify => Service[$agent_service],
  }

}
