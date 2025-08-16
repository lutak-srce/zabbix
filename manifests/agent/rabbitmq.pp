#
# = Class: zabbix::agent::rabbitmq
#
# This module installs RabbitMQ sensor
#
class zabbix::agent::rabbitmq (
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $username                = 'use_hiera',
  $password                = 'use_hiera',
  $rabbitmq_protocol       = 'http',
  $rabbitmq_hostname       = 'localhost',
  $rabbitmq_port           = '15672',
  $node                    = $facts['networking']['fqdn'],
  $senderhostname          = $facts['networking']['fqdn'],
) inherits zabbix::agent {

  file { "${conf_dir}/rabbitmq.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('zabbix/agent/rabbitmq.conf.erb'),
    require => [
      Package[$agent_package],
      File["${dir_zabbix_agent_libdir}/api.py"],
      File["${dir_zabbix_agent_libdir}/list_rabbit_nodes.sh"],
      File["${dir_zabbix_agent_libdir}/list_rabbit_queues.sh"],
      File["${dir_zabbix_agent_libdir}/rabbitmq-status.sh"],
      File["${dir_zabbix_agent_libdir}/.rab.auth"],
    ],
    notify  => Service[$agent_service],
  }

  file { "${dir_zabbix_agent_libdir}/api.py" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/rabbitmq/api.py',
  }
  file { "${dir_zabbix_agent_libdir}/list_rabbit_nodes.sh" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/rabbitmq/list_rabbit_nodes.sh',
  }
  file { "${dir_zabbix_agent_libdir}/list_rabbit_queues.sh" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/rabbitmq/list_rabbit_queues.sh',
  }
  file { "${dir_zabbix_agent_libdir}/rabbitmq-status.sh" :
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/rabbitmq/rabbitmq-status.sh',
  }
  file { "${dir_zabbix_agent_libdir}/.rab.auth" :
    ensure  => file,
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0640',
    content => template('zabbix/agent/rab.auth.erb'),
  }
}
