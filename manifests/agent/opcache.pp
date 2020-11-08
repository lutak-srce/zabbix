#
# = Class: zabbix::agent::opcache
#
# This module installs Zabbix PHP opcache sensor
#
class zabbix::agent::opcache (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $opcache_stats_loc           = 'https://localhost/opcache_stats.php',
  $opcache_stats_dir           = '/var/www/'
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/opcache.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/opcache.conf.erb'),
    require => [
      Package['zabbix-agent'],
      File["${dir_zabbix_agent_libdir}/zabbix-opcache.pl"],
    ],
    notify  => Service['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/zabbix-opcache.pl" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/zabbix-opcache.pl',
    require =>  [
      Package['zabbix-agent'],
    ],

  file { "${opcache_stats_dir}/opcache_stats.php" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/opcache_stats.php',
  }
}
