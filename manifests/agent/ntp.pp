# @summary 
#   Manages Zabbix agent configuration for ntp monitoring.
#
# @example
#   include zabbix::agent::ntp
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::ntp inherits zabbix::agent {
  case $facts['os']['family'] {
    /(RedHat|redhat)/: {

      $ntpq_bin = '/usr/sbin/ntpq'

      case $facts['os']['release']['major'] {
        /^(8|9)/: {
          file { "${zabbix::agent::conf_dir}/chrony.conf":
            ensure  => file,
            content => template('zabbix/agent/chrony.conf.erb'),
          }
        }
        default: {
          file { "${zabbix::agent::conf_dir}/ntp.conf":
            ensure  => file,
            content => template('zabbix/agent/ntp.conf.erb'),
          }
        }
      }

    }
    /(Debian|debian|Ubuntu|ubuntu)/: {

      $ntpq_bin = '/usr/bin/ntpq'

      file { "${zabbix::agent::conf_dir}/ntp.conf":
        ensure  => file,
        content => template('zabbix/agent/ntp.conf.erb'),
      }
    }
    default: { notify{'zabbix::agent::ntp module does not support this OS !!!': } }
  }
}
