#
# = Class: zabbix::agent::phpfpmopcache
#
# This module installs Zabbix php-fpm-opcache sensor
#
class zabbix::agent::phpfpmopcache (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${dir_zabbix_agentd_confd}/php-fpm-opcache.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/php-fpm-opcache.conf.erb'),
    require => [
      Package['zabbix-agent'],
      File["${dir_zabbix_agent_libdir}/php-fpm-opcache.php"],
    ],
    notify  => Service['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/php-fpm-opcache.php" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('zabbix/agent/php-fpm-opcache.php.erb'),
  }
}
