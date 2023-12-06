#
# = Class: zabbix::agent::postgresql
#
# This module installs zabbix postgresql sensor
#
class zabbix::agent::postgresql (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
  $dir_zabbix_pg_template  = "${dir_zabbix_agent_libdir}/postgresql",
  $zbx_monitor_user        = 'zbx_monitor',
#  $zbx_monitor_password,
  $zbx_monitor_password    = 'Passw0rd',
) inherits zabbix::agent {

#  if $zbx_monitor_password == undef or $zbx_monitor_password == '' {
#    fail('Error: zbx_monitor_password is not defined.')
#  }

#  if class_exists('profile::postgresql') {
  if defined(Class["profile::postgresql"]) {
  
    postgresql::server::role { $zbx_monitor_user:
      ensure   => 'present',
      password => $zbx_monitor_password,
      require  => Class['postgresql::server'],
    }

    postgresql::server::grant { "pg_monitor to ${zbx_monitor_user}":
      role       => $zbx_monitor_user,
      object     => 'DATABASE',
      privileges => 'pg_monitor',
      require    => Postgresql::Server::Role[$zbx_monitor_user],
    }

    file { $dir_zabbix_pg_template:
      ensure  => directory,
      owner   => 'zabbix',
      group   => 'zabbix',
      mode    => '0770',
      require => Package['zabbix-agent'],
    }

    file { "${dir_zabbix_pg_template}/postgresql":
      ensure  => directory,
      recurse => true,
      source  => 'puppet:///modules/zabbix/agent/postgresql',
      owner   => 'zabbix',
      group   => 'zabbix',
      mode    => '0770',
      require => File["$dir_zabbix_pg_template"],
    }

    file { "${dir_zabbix_agentd_confd}/postgresql.conf":
      ensure  => file,
      content => template('zabbix/postgresql.conf.erb'),
      require => Exec["${dir_zabbix_pg_template}/postgresql"],
    }

    postgresql::server::pg_hba_rule { 'zbx_monitor_localhost':
      type        => 'host',
      database    => 'all',
      user        => "${zbx_monitor_user}",
      address     => '127.0.0.1/32',
      auth_method => 'trust',
    }

  } else {

    warning('Class postgresql::globals is not included. zabbix::agent::postgresql will not be applied.')

  }
}
