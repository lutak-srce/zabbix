#
# = Class: zabbix::repo
#
# Sets up repo for Zabbix
#
class zabbix::repo (
  $version = '2.2',
) inherits zabbix::params {

  case $facts['os']['name'] {
    default         : {}
    /Ubuntu/        : {
      class { '::zabbix::repo::ubuntu':
        version => $version,
      }
    }
    /CentOS|RedHat/ : {
      class { '::zabbix::repo::redhat':
        version => $version,
      }
    }
  }

}
