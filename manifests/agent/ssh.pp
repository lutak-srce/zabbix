#
# = Class: zabbix::agent::ssh
#
# This module installs zabbix ssh plugin
#
class zabbix::agent::ssh (
  $options       = '',
  $conf_dir      = $::zabbix::agent::conf_dir,
  $agent_service = $::zabbix::agent::service_state,
  $agent_package = $::zabbix::agent::agent_package,
) inherits zabbix::agent {

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

  file { "${conf_dir}/ssh.conf" :
    ensure  => file,
    owner   => root,
    group   => root,
    content => template('zabbix/agent/ssh.conf.erb'),
    notify  => Service[$agent_service],
    require => ::Sudoers::Allowed_command['zabbix_ssh'],
  }

}
