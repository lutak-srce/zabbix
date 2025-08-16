#
# = Class: zabbix::agent::elasticsearch
#
# This module installs ElasticSearch sensor
#
class zabbix::agent::elasticsearch (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${conf_dir}/elasticsearch.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/elasticsearch.conf.erb'),
    require => [
      Package[$agent_package],
      File["${dir_zabbix_agent_libdir}/elasticsearch.rb"],
    ],
    notify  => Service[$agent_service],
  }

  file { "${dir_zabbix_agent_libdir}/elasticsearch.rb" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/elasticsearch/elasticsearch.rb',
  }

}
