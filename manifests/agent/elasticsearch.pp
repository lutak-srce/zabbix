# @summary 
#   Manages Zabbix agent configuration for elasticsearch monitoring.
#
# @example
#   include zabbix::agent::elasticsearch
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::elasticsearch inherits zabbix::agent {
  file { "${zabbix::agent::conf_dir}/elasticsearch.conf":
    ensure  => file,
    content => template('zabbix/agent/elasticsearch.conf.erb'),
    require => File["${zabbix::agent::dir_zabbix_agent_libdir}/elasticsearch.rb"],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/elasticsearch.rb":
    ensure => file,
    source => 'puppet:///modules/zabbix/agent/elasticsearch/elasticsearch.rb',
  }
}
