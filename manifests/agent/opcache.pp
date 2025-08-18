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
  # The apache base class must be included first because it is used by opcache sensor
  if ! defined(Class['apache']) {
    fail('You must include the apache base class before using opcache sensor')
  }

  file { "${zabbix::agent::conf_dir}/opcache.conf":
    ensure  => file,
    content => template('zabbix/agent/opcache.conf.erb'),
    require => File["${zabbix::agent::dir_zabbix_agent_libdir}/zabbix-opcache.pl"],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/zabbix-opcache.pl":
    ensure  => file,
    mode    => $zabbix::agent::lib_file_mode,
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
    notify  => Service[$zabbix::agent::service_state],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/opcache_stats.php":
    ensure => file,
    mode   => $zabbix::agent::lib_file_mode,
    source => 'puppet:///modules/zabbix/agent/opcache/opcache_stats.php',
  }
}
