#
# @summary
#   Helper class to install logtail package
#
# @example
#   include zabbix::agent::logtail
#
class zabbix::agent::logtail {

  case $facts['os']['family'] {
    default: {
      # No action taken. Install logtail manually
    }
    /(Debian|Ubuntu)/: {
      package { 'logtail':
        ensure => installed,
      }
    }
  }

}
