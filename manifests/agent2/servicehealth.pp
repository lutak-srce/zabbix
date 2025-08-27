# @summary
#   This class handles service health check on service events.
#
# @api private
#
class zabbix::agent2::servicehealth {
  exec { "check is ${zabbix::agent2::service_name} active":
    command   => "${zabbix::agent2::health_check} ${zabbix::agent2::service_name}",
    unless    => "${zabbix::agent2::health_check} ${zabbix::agent2::service_name}",
  }
}
