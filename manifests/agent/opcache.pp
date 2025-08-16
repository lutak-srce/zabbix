#
# = Class: zabbix::agent::opcache
#
# This module installs Zabbix PHP opcache sensor
#
class zabbix::agent::opcache (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $host                    = 'localhost',
) inherits zabbix::agent {

  include apache

  file { "${conf_dir}/opcache.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/opcache.conf.erb'),
    require => [
      Package[$agent_package],
      File["${dir_zabbix_agent_libdir}/zabbix-opcache.pl"],
    ],
    notify  => Service[$agent_service],
  }

  file { "${dir_zabbix_agent_libdir}/zabbix-opcache.pl" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/opcache/zabbix-opcache.pl',
    require =>  [
      Package[$agent_package],
    ],
  }

  file { "${apache::confd_dir}/opcache_stats.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/opcache_stats.conf.erb'),
    require => [
      Package[$agent_package],
      File["${dir_zabbix_agent_libdir}/zabbix-opcache.pl"],
    ],
    notify  => Service[$agent_service],
  }

  file { "${dir_zabbix_agent_libdir}/opcache_stats.php" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/opcache/opcache_stats.php',
    notify => Class['apache::service'],
  }
}
