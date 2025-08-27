# @summary
#   This class handles zabbix agent2 service
#
# @api private
#
class zabbix::agent2::service {
  service { $zabbix::agent2::service_name:
    ensure => $zabbix::agent2::service_ensure,
    enable => $zabbix::agent2::service_enable,
  }
}
