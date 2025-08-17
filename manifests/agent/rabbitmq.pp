# @summary 
#   Manages Zabbix agent configuration for rabbitmq monitoring.
#
# @example
#   include zabbix::agent::rabbitmq
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::rabbitmq (
  $username          = 'use_hiera',
  $password          = 'use_hiera',
  $rabbitmq_protocol = 'http',
  $rabbitmq_hostname = 'localhost',
  $rabbitmq_port     = '15672',
  $node              = $facts['networking']['fqdn'],
  $senderhostname    = $facts['networking']['fqdn'],
) inherits zabbix::agent {
  file { "${zabbix::agent::conf_dir}/rabbitmq.conf":
    ensure  => file,
    content => template('zabbix/agent/rabbitmq.conf.erb'),
    require => [
      File["${zabbix::agent::dir_zabbix_agent_libdir}/api.py"],
      File["${zabbix::agent::dir_zabbix_agent_libdir}/list_rabbit_nodes.sh"],
      File["${zabbix::agent::dir_zabbix_agent_libdir}/list_rabbit_queues.sh"],
      File["${zabbix::agent::dir_zabbix_agent_libdir}/rabbitmq-status.sh"],
      File["${zabbix::agent::dir_zabbix_agent_libdir}/.rab.auth"],
    ],
  }

  file { "${zabbix::agent::dir_zabbix_agent_libdir}/api.py":
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/rabbitmq/api.py',
  }
  file { "${zabbix::agent::dir_zabbix_agent_libdir}/list_rabbit_nodes.sh":
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/rabbitmq/list_rabbit_nodes.sh',
  }
  file { "${zabbix::agent::dir_zabbix_agent_libdir}/list_rabbit_queues.sh":
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/rabbitmq/list_rabbit_queues.sh',
  }
  file { "${zabbix::agent::dir_zabbix_agent_libdir}/rabbitmq-status.sh":
    ensure => file,
    mode   => '0755',
    source => 'puppet:///modules/zabbix/agent/rabbitmq/rabbitmq-status.sh',
  }
  file { "${zabbix::agent::dir_zabbix_agent_libdir}/.rab.auth":
    ensure  => file,
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0640',
    content => template('zabbix/agent/rab.auth.erb'),
  }
}
