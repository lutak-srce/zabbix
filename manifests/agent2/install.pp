# @summary
#   This class installs zabbix agent2 package.
#
# @api private
#
class zabbix::agent2::install {
  package { $zabbix::agent2::package_name:
    ensure => $zabbix::agent2::package_ensure,
  }
}
