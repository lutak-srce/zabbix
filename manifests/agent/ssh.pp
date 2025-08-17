# @summary 
#   Manages Zabbix agent configuration for sshd monitoring.
#
# @example
#   include zabbix::agent::ssh
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::ssh inherits zabbix::agent {
  case $facts['os']['family'] {
    default: {
      $lsof_bin = '/usr/sbin/lsof'
    }
    /(RedHat|redhat|amazon)/: {
      case $facts['os']['release']['full'] {
        default: {
          $lsof_bin = '/usr/bin/lsof'
        }
        /^(5|6|7).*/: {
          $lsof_bin = '/usr/sbin/lsof'
        }
      }
    }
    /(Debian|debian|Ubuntu|ubuntu)/: {
      $lsof_bin = '/usr/bin/lsof'
    }
  }

  ::sudoers::allowed_command { 'zabbix_ssh':
    command          => "${lsof_bin} -i -n -l -P",
    user             => 'zabbix',
    require_password => false,
    comment          => 'Zabbix sensor for monitoring SSH.',
  }

  file { "${zabbix::agent::conf_dir}/ssh.conf" :
    ensure  => file,
    content => template('zabbix/agent/ssh.conf.erb'),
    require => ::Sudoers::Allowed_command['zabbix_ssh'],
  }

}
