# @summary 
#   Manages Zabbix agent configuration for mysql slave monitoring.
#
# @example
#   include zabbix::agent::mysql::slave
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::mysql::slave (
  $options = '',
) inherits zabbix::agent {
  file { "${zabbix::agent::conf_dir}/mysql-slave.conf":
    ensure  => file,
    content => template('zabbix/agent/mysql-slave.conf.erb'),
  }

  mysql_user { 'zabbix@localhost':
    ensure        => present,
    password_hash => mysql::password('*DCF0B12208AA8B60055A57AF91EAE4702832791B'),
  }

  if $facts['os']['family'] == 'Debian' and $facts['os']['release']['major'] > '10' {
    mysql_grant { 'zabbix@localhost/*.*':
      ensure     => present,
      privileges => ['BINLOG MONITOR', 'SLAVE MONITOR'],
      table      => '*.*',
      user       => 'zabbix@localhost',
      options    => ['NONE'],
    }
  } else {
    mysql_grant { 'zabbix@localhost/*.*':
      ensure     => present,
      privileges => ['REPLICATION CLIENT'],
      table      => '*.*',
      user       => 'zabbix@localhost',
      options    => ['NONE'],
    }
  }
}
