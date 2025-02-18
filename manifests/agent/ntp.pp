#
# = Class: zabbix::agent::ntp
#
# This module installs zabbix ntp plugin
#
class zabbix::agent::ntp (
  $dir_zabbix_agentd_confd = $::zabbix::agent::dir_zabbix_agentd_confd,
) inherits zabbix::agent {

  case $facts['os']['family'] {
    /(RedHat|redhat)/: {

      $ntpq_bin = '/usr/sbin/ntpq'

      case $facts['os']['release']['major'] {
        /^(8|9)/ : {
          file { "${dir_zabbix_agentd_confd}/chrony.conf" :
            ensure  => file,
            owner   => root,
            group   => root,
            content => template('zabbix/agent/chrony.conf.erb'),
            notify  => Service['zabbix-agent'],
          }
        }
        default: {
          file { "${dir_zabbix_agentd_confd}/ntp.conf" :
            ensure  => file,
            owner   => root,
            group   => root,
            content => template('zabbix/agent/ntp.conf.erb'),
            notify  => Service['zabbix-agent'],
          }
        }
      }

    }
    /(Debian|debian|Ubuntu|ubuntu)/: {

      $ntpq_bin = '/usr/bin/ntpq'

      file { "${dir_zabbix_agentd_confd}/ntp.conf" :
        ensure  => file,
        owner   => root,
        group   => root,
        content => template('zabbix/agent/ntp.conf.erb'),
        notify  => Service['zabbix-agent'],
      }
    }

    default: { notify{'zabbix::agent::ntp module does not support this OS !!!': } }

  }

}
