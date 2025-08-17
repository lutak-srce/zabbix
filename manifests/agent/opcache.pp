# @summary 
#   Manages Zabbix agent configuration for opcache monitoring.
#
# @example
#   include zabbix::agent::opcache
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::opcache (
  $host = 'localhost',
) inherits zabbix::agent {
  include apache

  file { "${zabbix::agent::conf_dir}/opcache.conf":
    ensure  => file,
    content => template('zabbix/agent/opcache.conf.erb'),
    require => File["${zabbix::agent::dir_zabbix_agent_libdir}/zabbix-opcache.pl"],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/zabbix-opcache.pl":
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/zabbix/agent/opcache/zabbix-opcache.pl',
  }

  file { "${apache::confd_dir}/opcache_stats.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/opcache_stats.conf.erb'),
    require => [
      Package[$zabbix::agent::agent_package],
      File["${zabbix::agent::dir_zabbix_agent_libdir}/zabbix-opcache.pl"],
    ],
    notify  => Service[$zabbix::agent::agent_service],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/opcache_stats.php":
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/opcache/opcache_stats.php',
  }
}
