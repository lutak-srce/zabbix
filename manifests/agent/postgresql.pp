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
  $zbx_monitor_password    = lookup({
    'name' => 'zabbix::agent::postgresql::zbx_monitor_password',
    'merge' => { 'strategy' => 'deep' },
    'default_value' => 'undef'
    }),

) inherits zabbix::agent {

  if $zbx_monitor_password == undef or $zbx_monitor_password == '' {
    fail('Error: zbx_monitor_password is not defined.')
  }

  if defined(Class["profile::postgresql"]) {
  
    postgresql::server::role { $zbx_monitor_user:
      ensure        => 'present',
      password_hash => $zbx_monitor_password,
      require       => Class['postgresql::server'],
    }

    postgresql::server::grant_role { "grant_pg_monitor_to_${zbx_monitor_user}":
      role    => $zbx_monitor_user,
      group   => 'pg_monitor',
      require => Postgresql::Server::Role[$zbx_monitor_user],
    }

    file { "$dir_zabbix_pg_template":
      ensure  => directory,
      recurse => true,
      source  => 'puppet:///modules/zabbix/agent/postgresql',
      owner   => 'zabbix',
      group   => 'zabbix',
      mode    => '0770',
      require => Package['zabbix-agent'],
    }

    file { "${dir_zabbix_agentd_confd}/postgresql.conf":
      ensure  => file,
      content => template('zabbix/agent/postgresql.conf.erb'),
      require => File["$dir_zabbix_pg_template"],
    }

    postgresql::server::pg_hba_rule { 'zbx_monitor_localhost':
      type        => 'host',
      database    => 'all',
      user        => "${zbx_monitor_user}",
      address     => '127.0.0.1/32',
      auth_method => 'trust',
    }

  } else {

    fail('Error: class profile::postgresql is not included. zabbix::agent::postgresql will not be applied.')

  }
}
