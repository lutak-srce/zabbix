# @summary
#   This class handles zabbix agent2 service
#   and executes service health check on service events.
#
# @api private
#
class zabbix::agent2::service {
  service { $zabbix::agent2::service_name:
    ensure  => $zabbix::agent2::service_ensure,
    enable  => $zabbix::agent2::service_enable,
  }

  exec { "check is ${zabbix::agent2::service_name} active":
    command   => "${zabbix::agent2::health_check} ${zabbix::agent2::service_name}",
    unless    => "${zabbix::agent2::health_check} ${zabbix::agent2::service_name}",
    subscribe => Service[$zabbix::agent2::service_name],
  }
}
