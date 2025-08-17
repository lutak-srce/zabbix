# @summary 
#   Manages Zabbix agent configuration for mysql monitoring.
#
# @example
#   include zabbix::agent::mysql
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::mysql (
  $options = '',
) inherits zabbix::agent {
  package { 'zabbix-agent_mysql':
    ensure  => present,
    require => Package[$zabbix::agent::agent_package],
  }

  file { "${zabbix::agent::conf_dir}/mysql.conf":
    ensure  => file,
    content => template('zabbix/agent/mysql.conf.erb'),
    require => Package['zabbix-agent_mysql'],
  }
}
