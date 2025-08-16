#
# = Class: zabbix::agent::ntp
#
# This module installs zabbix ntp plugin
#
class zabbix::agent::ntp (
  $conf_dir      = $::zabbix::agent::conf_dir,
  $agent_service = $::zabbix::agent::service_state,
  $agent_package = $::zabbix::agent::agent_package,
) inherits zabbix::agent {

  case $facts['os']['family'] {
    /(RedHat|redhat)/: {

      $ntpq_bin = '/usr/sbin/ntpq'

      case $facts['os']['release']['major'] {
        /^(8|9)/ : {
          file { "${conf_dir}/chrony.conf" :
            ensure  => file,
            owner   => root,
            group   => root,
            content => template('zabbix/agent/chrony.conf.erb'),
            notify  => Service[$agent_service],
          }
        }
        default: {
          file { "${conf_dir}/ntp.conf" :
            ensure  => file,
            owner   => root,
            group   => root,
            content => template('zabbix/agent/ntp.conf.erb'),
            notify  => Service[$agent_service],
          }
        }
      }

    }
    /(Debian|debian|Ubuntu|ubuntu)/: {

      $ntpq_bin = '/usr/bin/ntpq'

      file { "${conf_dir}/ntp.conf" :
        ensure  => file,
        owner   => root,
        group   => root,
        content => template('zabbix/agent/ntp.conf.erb'),
        notify  => Service[$agent_service],
      }
    }

    default: { notify{'zabbix::agent::ntp module does not support this OS !!!': } }

  }

}
