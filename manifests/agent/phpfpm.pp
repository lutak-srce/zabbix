#
# = Class: zabbix::agent::phpfpm
#
# This module installs Zabbix php-fpm sensor
#
class zabbix::agent::phpfpm (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $php_fpm_sock	           = 'undef'
) inherits zabbix::agent {

  if $php_fpm_sock == undef {
    fail('Variable $php_fpm_sock must be defined (php-fpm listening socket)')
  }

  file { "${dir_zabbix_agentd_confd}/php-fpm.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    source => 'puppet:///modules/zabbix/agent/php-fpm/php-fpm.conf',
    require => [
      Package['zabbix-agent'],
      File["${dir_zabbix_agent_libdir}/php-fpm.sh"],
      Package['fcgi'],
    ],
    notify  => Service['zabbix-agent'],
  }

  file { "${dir_zabbix_agent_libdir}/php-fpm.sh" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    content => template('zabbix/agent/php-fpm.sh.erb'),
  }

  file { "/etc/sudoers.d/zabbix_php-fpm" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0440',
    source => 'puppet:///modules/zabbix/agent/php-fpm/zabbix_php-fpm',
  }

}
