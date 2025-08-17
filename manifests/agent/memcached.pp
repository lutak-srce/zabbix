# @summary 
#   Manages Zabbix agent configuration for memcached monitoring.
#
# @example
#   include zabbix::agent::memcached
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::memcached inherits zabbix::agent {
  file { "${zabbix::agent::conf_dir}/memcached.conf":
    ensure  => file,
    content => template('zabbix/agent/memcached.conf.erb'),
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/memcached.pl":
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/memcached.pl',
  }
}
