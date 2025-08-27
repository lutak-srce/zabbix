# @summary
#   This class purges zabbix agent package.
#
# @api private
#
class zabbix::agent2::preinstall {
  package { $zabbix::agent2::zabbix_agent:
    ensure => $zabbix::agent2::zabbix_agent_ensure,
  }
}
