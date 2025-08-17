# @summary 
#   Manages Zabbix agent configuration for counting pending upgrades.
#
# @example
#   include zabbix::agent::pkgupgrades
#
# @note 
#   This class inherits all parameters from zabbix::agent class.
#
class zabbix::agent::pkgupgrades inherits zabbix::agent {

  case $facts['os']['family'] {
    default: {}
    /(RedHat|redhat|amazon)/: {
      file { "${zabbix::agent::conf_dir}/pkgupgrades.conf" :
        ensure  => file,
        content => template('zabbix/agent/pkgupgrades-rhel.conf.erb'),
      }

      ::sudoers::allowed_command { 'zabbix_yum':
        command          => '/usr/bin/yum -y -q check-update',
        user             => 'zabbix',
        require_password => false,
        comment          => 'Zabbix sensor for monitoring packages pending upgrade.',
      }
    }
    /(Debian|debian|Ubuntu|ubuntu)/: {
      file { "${zabbix::agent::conf_dir}/pkgupgrades.conf" :
        ensure  => file,
        content => template('zabbix/agent/pkgupgrades-debian.conf.erb'),
      }
    }
  }
}
