#
# = Class: zabbix::agent::mysql::slave
#
# This module installs zabbix mysql slave sensor
#
class zabbix::agent::mysql::slave (
  $options                 = '',
  $conf_dir                = $::zabbix::agent::conf_dir,
  $agent_service           = $::zabbix::agent::service_state,
  $agent_package           = $::zabbix::agent::agent_package,
  $dir_zabbix_agent_libdir = $::zabbix::agent::dir_zabbix_agent_libdir,
) inherits zabbix::agent {

  file { "${conf_dir}/mysql-slave.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/mysql-slave.conf.erb'),
    notify  => Service[$agent_service],
  }

  mysql_user { 'zabbix@localhost':
    ensure        => present,
    password_hash => mysql::password('*DCF0B12208AA8B60055A57AF91EAE4702832791B'),
  }


  # packages on CentOS 8
  if $facts['os']['family'] == 'Debian' and $facts['os']['release']['major'] > '10' {
    mysql_grant { 'zabbix@localhost/*.*':
      ensure     => present,
      privileges => ['BINLOG MONITOR', 'SLAVE MONITOR'],
      table      => '*.*',
      user       => 'zabbix@localhost',
      options    => ['NONE'],
    }
  }

  else {
    mysql_grant { 'zabbix@localhost/*.*':
      ensure     => present,
      privileges => ['REPLICATION CLIENT'],
      table      => '*.*',
      user       => 'zabbix@localhost',
      options    => ['NONE'],
    }
  }

}
