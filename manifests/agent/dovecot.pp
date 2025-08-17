# @summary 
#   Manages Zabbix agent configuration for Dovecot server monitoring.
#
# @example
#   include zabbix::agent::dovecot
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::dovecot inherits zabbix::agent {
  include zabbix::agent::logtail

  file { "${zabbix::agent::conf_dir}/dovecot.conf":
    ensure  => file,
    content => template('zabbix/agent/dovecot.conf.erb'),
    require => File["${zabbix::agent::dir_zabbix_agent_libdir}/dovecot.pl"],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/dovecot.pl":
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/dovecot.pl',
  }
}
