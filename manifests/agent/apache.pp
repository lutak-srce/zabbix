# @summary 
#   Manages Zabbix agent configuration for Apache server monitoring.
#
# @example
#   include zabbix::agent::apache
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::apache (
  $status_address = 'localhost',
) inherits zabbix::agent {

  package { 'curl':
    ensure => present,
  }

  file { "${zabbix::agent::conf_dir}/apache2.conf":
    ensure  => file,
    content => template('zabbix/agent/apache2.conf.erb'),
    require => File["${zabbix::agent::dir_zabbix_agent_libdir}/apache2.pl"],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/apache2.pl":
    ensure  => file,
    mode    => $zabbix::agent::lib_file_mode,
    content => template('zabbix/agent/apache2.pl.erb'),
    require => Package['curl'],
  }
}
